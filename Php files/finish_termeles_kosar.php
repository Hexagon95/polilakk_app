<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql/sql_commands.php';
include 'sql/altered_database_managers/dm_id_userid_output.php';

$task = new Task();
echo json_encode($task->getResult());

class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){
        $this->_inizialite();        
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_termelesKosarZaras(),
            [
                'id' =>         $this->request['id'],
                'user_id' =>    $this->request['user_id']
            ],
            $this->request['customer']
        );
        $this->result =             $this->databaseManager->getData();
    }
}