<?php
class DatabaseManager{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $pdoServer =   "localhost\\SQLEXPRESS,1433";
    private $pdoUser =     "KoatSQL";
    private $pdoPassword = "1@bD38Wz9k!";
    private $data;
    public function getData(){return $this->data;}
    public $conn;

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($queryString, $parameters = [], $pdoDatabase = "Koat2"){
        $this->_connect($pdoDatabase);
        $this->_executeQuery($queryString, $parameters);
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _connect($pdoDatabase){
        try{
            $this->conn = new PDO("sqlsrv:Server=$this->pdoServer;Database=$pdoDatabase;", $this->pdoUser, $this->pdoPassword);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        }
        catch(\Throwable $th){
            echo json_encode(array(['Connection failed' => $th->getMessage()]));
        }
    }

    private function _executeQuery($queryString, $parameters){
        try{
            $outputId = 0;
            $output = '';

            $sqlQuery = $this->conn->prepare($queryString);
            $sqlQuery->bindParam(':input1', $parameters['input1'], PDO::PARAM_STR);
            $sqlQuery->bindParam(':input2', $parameters['input2'], PDO::PARAM_STR);
            $sqlQuery->bindParam(':id', $parameters['id'], PDO::PARAM_INT);
            $sqlQuery->bindParam(':outputid', $outputId, PDO::PARAM_INT|PDO::PARAM_INPUT_OUTPUT, 10);
            $sqlQuery->bindParam(':output', $output, PDO::PARAM_STR|PDO::PARAM_INPUT_OUTPUT, 4000);
            $sqlQuery->execute();

            $this->data = [
                'outputid' => $outputId,
                'output' => $output
            ];
        }
        catch(\Throwable $th){
            echo $th->getMessage();
        }
    }
}