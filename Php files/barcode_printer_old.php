<?php
session_start();

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
ini_set('memory_limit', '4096M');
error_reporting(E_ERROR);
date_default_timezone_set('Europe/Budapest');


$_SESSION['mosaic_company_database_name'] = "Koat2";

include "../config.php";
include "../functions.php";


$UserName	=	"KoatSQL";
$Password	=	"1@bD38Wz9k!";
$ID			=	( isset($_POST['ID']) ? $_POST['ID'] : 0  );
$Identity	=	( isset($_POST['ID']) ? $_POST['Identity'] : 0  );

file_put_contents("../logs/a.log", json_encode($_POST, JSON_PRETTY_PRINT)."\n\r", FILE_APPEND);

$parameter =
	array("Header" => array(
		"UserName" => $UserName,
		"Password" => $Password,
		"OsSerialNumber" => "",
		"ID" => $ID,
		"Identity" => $Identity
	)) ;
	
$OutputTemp		=	array();
		$params = array();
		array_push($params, array("name" => ":parameter", "value" => json_encode($parameter, JSON_PRETTY_PRINT), "type" => PDO::PARAM_STR)); 
		array_push($params, array("name" => ":output", "value" => $OutputTemp, "type" => PDO::PARAM_STR|PDO::PARAM_INPUT_OUTPUT, "maxLength" => 4000, "isReturn" => true));               

		$sql = "EXEC [dbo].[BarcodePrint] :parameter, :output";
		$query = $SQLPDO->SQLCommandToOutputMessage($sql, $params);
		$OutputTemp		=	"";
	
		$OutputTemp = json_decode($SQLPDO->OutputMessage, true);	

$SQLPDO->Close();
header( 'Content-Type: application/json' );
file_put_contents("../logs/a.log", json_encode($OutputTemp, JSON_PRETTY_PRINT)."\n\r", FILE_APPEND);
print json_encode($OutputTemp);