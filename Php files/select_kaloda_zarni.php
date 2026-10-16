<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql/sql_commands.php';
include 'sql/database_manager.php';

$task = new Task();
echo json_encode($task->getResult());

class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $result;

    public function getResult(){
        return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){
        $this->_inizialite();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =    json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand = new SqlCommand();

        if((string)($this->request['menu'] ?? '') === '6'){
            $this->databaseManager = new DatabaseManager(
                $this->sqlCommand->select_termelesFolyamat6KalodaZarni(),
                [],
                $this->request['customer']
            );
        }else{
            $this->databaseManager = new DatabaseManager(
                $this->sqlCommand->select_termelesFolyamat5KalodaZarni(),
                [],
                $this->request['customer']
            );
        }

        $this->result = $this->databaseManager->getData();
    }
}