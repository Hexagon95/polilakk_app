<?php
header('Content-Type: application/json; charset=utf-8');

include 'sql/sql_commands.php';
include 'sql/altered_database_managers/dm_parameter_output.php';

$task = new Task();
echo json_encode($task->getResult(), JSON_UNESCAPED_UNICODE);

class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $result;
    public function getResult(){return $this->result;}

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){
        $this->_initialize();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _initialize(){
        $this->request = $_POST;
        $parameter = [
            'Header' => [
                'UserName' => '',
                'Password' => '',
                'OsSerialNumber' => '',
                'ID' => (int)($this->request['ID'] ?? 0),
                'Identity' => (int)($this->request['Identity'] ?? 0)
            ]
        ];
        $this->sqlCommand = new SqlCommand();
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_barcodePrint(),
            [
                'parameter' => json_encode($parameter, JSON_UNESCAPED_UNICODE)
            ],
            'Koat2'
        );
        $output = $this->databaseManager->getData();
        if(is_string($output)){
            $decoded = json_decode($output, true);
            $this->result = $decoded ?? ['Datas' => []];
            return;
        }
        $this->result = $output ?? ['Datas' => []];
    }
}