<?php
header('Content-Type: application/json; charset=utf-8');

include 'sql/sql_commands.php';
include 'sql/database_manager.php';

const LABEL_WIDTH = 800;
const LABEL_HEIGHT = 1216;

const MARGIN_LEFT = 30;
const MARGIN_RIGHT = 30;
const HEADER_HEIGHT = 190;
const BOTTOM_MARGIN = 30;
const TOP_OFFSET = 20;

const ORDER_HEADER_HEIGHT = 55;
const ITEM_FIRST_ROW_HEIGHT = 60;
const ITEM_COLOR_ROW_HEIGHT = 70;
const ITEM_HEIGHT = ITEM_FIRST_ROW_HEIGHT + ITEM_COLOR_ROW_HEIGHT;
const GROUP_SPACING = 15;

const PRINT_FOLYAMAT_ID = 5;

try{
    $input = json_decode(file_get_contents('php://input'), true);
    if(!is_array($input)) throw new Exception('Érvénytelen JSON.');
    $customer = trim((string)($input['customer'] ?? ''));
    $cimkeId = (int)($input['id'] ?? 0);
    if($customer === '') throw new Exception('Hiányzó customer.');
    if($cimkeId <= 0) throw new Exception('Érvénytelen címke ID.');
    $sqlCommand = new SqlCommand();
    $databaseManager = new DatabaseManager(
        $sqlCommand->select_termelesFolyamat5KalodaCimke(),
        [
            'id' => $cimkeId
        ],
        $customer
    );
    $sqlResult = $databaseManager->getData();
    if(!is_array($sqlResult) || empty($sqlResult) || !isset($sqlResult[0]['b'])) throw new Exception('Nem található címke adat.');
    $labelData = json_decode($sqlResult[0]['b'], true);
    if(!is_array($labelData)) throw new Exception('Hibás címke JSON.');
    if(!isset($labelData['kaloda_id'])) throw new Exception('Hiányzó kaloda_id.');
    if(!isset($labelData['qrcode'])) throw new Exception('Hiányzó qrcode.');
    if(!isset($labelData['tetelek']) || !is_array($labelData['tetelek'])) throw new Exception('Hiányzó tetelek tömb.');
    $kalodaId = $labelData['kaloda_id'];
    $qrCode = $labelData['qrcode'];
    $groups = groupByOrder($labelData['tetelek']);
    $pages = paginateGroups($groups);
    $zpl = generateZpl($kalodaId, $qrCode, $pages);
    $printerResponse = sendToPrintQueue(
        $zpl,
        $customer
    );
    echo json_encode([
        'success' => true,
        'labels' => count($pages),
        'kaloda_id' => $kalodaId,
        'cimke_id' => $cimkeId,
        'print_folyamat_id' => PRINT_FOLYAMAT_ID,
        'zpl' => $zpl,
        'printer_response' => $printerResponse
    ], JSON_UNESCAPED_UNICODE);
}
catch(Throwable $e){
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

function groupByOrder(array $items): array{
    $groups = [];
    foreach($items as $item){
        $order = trim((string)($item['rendeles'] ?? ''));
        if($order === '') $order = 'NINCS RENDELES';
        if(!isset($groups[$order])) $groups[$order] = [];
        $groups[$order][] = $item;
    }
    return $groups;
}

function paginateGroups(array $groups): array{
    $availableHeight = LABEL_HEIGHT - HEADER_HEIGHT - TOP_OFFSET - BOTTOM_MARGIN;
    $pages = [];
    $currentPage = [];
    $usedHeight = 0;
    foreach($groups as $order => $items){
        $groupHeight = getGroupHeight(count($items));
        if($groupHeight <= $availableHeight){
            if($usedHeight > 0 && $usedHeight + $groupHeight > $availableHeight){
                $pages[] = $currentPage;
                $currentPage = [];
                $usedHeight = 0;
            }
            $currentPage[] = [
                'rendeles' => $order,
                'tetelek' => $items
            ];
            $usedHeight += $groupHeight;
            continue;
        }
        if(!empty($currentPage)){
            $pages[] = $currentPage;
            $currentPage = [];
            $usedHeight = 0;
        }
        $maxItemsPerPage = (int)floor(($availableHeight - ORDER_HEADER_HEIGHT - GROUP_SPACING) / ITEM_HEIGHT);
        if($maxItemsPerPage < 1) $maxItemsPerPage = 1;
        $chunks = array_chunk($items, $maxItemsPerPage);
        foreach($chunks as $chunk){
            $pages[] = [[
                'rendeles' => $order,
                'tetelek' => $chunk
            ]];
        }
    }
    if(!empty($currentPage)) $pages[] = $currentPage;
    return $pages;
}

function getGroupHeight(int $itemCount): int{
    return ORDER_HEADER_HEIGHT + ($itemCount * ITEM_HEIGHT) + GROUP_SPACING;
}

function generateZpl($kalodaId, string $qrCode, array $pages): string{
    $zpl = '';
    foreach($pages as $pageIndex => $groups){
        $zpl .= generateLabel(
            $kalodaId,
            $qrCode,
            $groups,
            $pageIndex + 1,
            count($pages)
        );
    }
    return $zpl;
}

function generateLabel(
    $kalodaId,
    string $qrCode,
    array $groups,
    int $pageNumber,
    int $pageCount
): string{
    $zpl = "^XA\n";
    $zpl .= "^CI28\n";
    $zpl .= "^PW" . LABEL_WIDTH . "\n";
    $zpl .= "^LL" . LABEL_HEIGHT . "\n";
    $zpl .= "^LH0,0\n";
    $zpl .= "^FO35," . (45 + TOP_OFFSET) . "^A0N,46,46^FD" . zplEscape("KALODA #$kalodaId") . "^FS\n";
    if($pageCount > 1) $zpl .= "^FO35," . (105 + TOP_OFFSET) . "^A0N,24,24^FD" . zplEscape("$pageNumber / $pageCount") . "^FS\n";
    $zpl .= "^FO630," . (30 + TOP_OFFSET) . "^BQN,2,4^FDLA," . zplEscape($qrCode) . "^FS\n";
    $zpl .= "^FO30," . (175 + TOP_OFFSET) . "^GB740,3,3^FS\n";
    $y = HEADER_HEIGHT + TOP_OFFSET;
    foreach($groups as $group){
        $zpl .= generateGroup($group, $y);
        $y += getGroupHeight(count($group['tetelek']));
    }
    $zpl .= "^XZ\n";
    return $zpl;
}

function generateGroup(array $group, int $startY): string{
    $order = $group['rendeles'];
    $items = $group['tetelek'];
    $x = MARGIN_LEFT;
    $width = LABEL_WIDTH - MARGIN_LEFT - MARGIN_RIGHT;
    $columnWidth = (int)floor($width / 3);
    $y = $startY;
    $zpl = '';
    $zpl .= "^FO$x,$y^GB$width,3,3^FS\n";
    $y += 12;
    $zpl .= "^FO" . ($x + 10) . ",$y^A0N,32,32^FD" . zplEscape("Rendeles: $order") . "^FS\n";
    $y = $startY + ORDER_HEADER_HEIGHT;
    foreach($items as $item){
        $firstRowY = $y;
        $colorRowY = $firstRowY + ITEM_FIRST_ROW_HEIGHT;
        $zpl .= "^FO$x,$firstRowY^GB$width," . ITEM_FIRST_ROW_HEIGHT . ",2^FS\n";
        $zpl .= "^FO$x,$colorRowY^GB$width," . ITEM_COLOR_ROW_HEIGHT . ",2^FS\n";
        $zpl .= "^FO" . ($x + $columnWidth) . ",$firstRowY^GB2," . ITEM_FIRST_ROW_HEIGHT . ",2^FS\n";
        $zpl .= "^FO" . ($x + ($columnWidth * 2)) . ",$firstRowY^GB2," . ITEM_FIRST_ROW_HEIGHT . ",2^FS\n";
        $cikkszam = zplEscape((string)($item['cikkszam'] ?? '-'));
        $db = zplEscape((string)($item['db'] ?? '-'));
        $hossz = zplEscape((string)($item['hossz'] ?? '-'));
        $szin = zplEscape((string)($item['szin'] ?? '-'));
        $zpl .= "^FO" . ($x + 8) . "," . ($firstRowY + 18) . "^A0N,25,25^FB" . ($columnWidth - 16) . ",1,0,C,0^FD$cikkszam^FS\n";
        $zpl .= "^FO" . ($x + $columnWidth + 8) . "," . ($firstRowY + 18) . "^A0N,25,25^FB" . ($columnWidth - 16) . ",1,0,C,0^FD$db db^FS\n";
        $zpl .= "^FO" . ($x + ($columnWidth * 2) + 8) . "," . ($firstRowY + 18) . "^A0N,25,25^FB" . ($columnWidth - 16) . ",1,0,C,0^FD$hossz mm^FS\n";
        $zpl .= "^FO" . ($x + 10) . "," . ($colorRowY + 14) . "^A0N,24,24^FB" . ($width - 20) . ",2,2,C,0^FD$szin^FS\n";
        $y += ITEM_HEIGHT;
    }
    $zpl .= "^FO$x,$y^GB$width,3,3^FS\n";
    return $zpl;
}

function zplEscape(string $value): string{
    $value = strtr($value, [
        'á' => 'a',
        'é' => 'e',
        'í' => 'i',
        'ó' => 'o',
        'ö' => 'o',
        'ő' => 'o',
        'ú' => 'u',
        'ü' => 'u',
        'ű' => 'u',
        'Á' => 'A',
        'É' => 'E',
        'Í' => 'I',
        'Ó' => 'O',
        'Ö' => 'O',
        'Ő' => 'O',
        'Ú' => 'U',
        'Ü' => 'U',
        'Ű' => 'U'
    ]);
    $value = str_replace('^', ' ', $value);
    $value = str_replace('~', ' ', $value);
    return trim($value);
}

function sendToPrintQueue(
    string $zpl,
    string $customer
){
    $sqlCommand = new SqlCommand();
    $databaseManager = new DatabaseManager(
        $sqlCommand->exec_barcodePrintFelvitel(),
        [
            'zpl_kod' => $zpl,
            'folyamat_id' => PRINT_FOLYAMAT_ID,
            'ip' => ''
        ],
        $customer
    );
    return $databaseManager->getData();
}