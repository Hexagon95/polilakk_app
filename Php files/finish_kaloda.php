<?php
header('Content-Type: application/json; charset=utf-8');

$request = json_decode(file_get_contents('php://input'), true);
$menu = (int)($request['menu'] ?? 5);

include 'sql/sql_commands.php';

if($menu === 6){
    include 'sql/altered_database_managers/dm_input1_id_outputid_output.php';
}else{
    include 'sql/altered_database_managers/dm_input1_input2_id_outputid_output.php';
}

$task = new Task($request, $menu);
echo json_encode($task->getResult());

class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $result;
    private $menu;

    public function getResult(){return $this->result;}

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($request, $menu){
        $this->request = $request;
        $this->menu = $menu;
        $this->_inizialite();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->sqlCommand = new SqlCommand();

        if($this->menu === 6){
            $this->databaseManager = new DatabaseManager(
                $this->sqlCommand->exec_termeles6KalodaFelvitel(),
                [
                    'input1' => $this->request['gorgozes'],
                    'id' =>     $this->request['user_id']
                ],
                $this->request['customer']
            );
        }else{
            $this->databaseManager = new DatabaseManager(
                $this->sqlCommand->exec_termeles5KalodaFelvitel(),
                [
                    'input1' => $this->request['vedofoliazas'],
                    'input2' => $this->request['gorgozes'],
                    'id' =>     $this->request['user_id']
                ],
                $this->request['customer']
            );
        }

        $this->result = $this->databaseManager->getData();
    }
}