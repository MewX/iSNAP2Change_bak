<?php

	session_start();

	require_once('../mysql-lib.php');
	require_once('../debug.php');
	$pageName = "login";

	if ($_SERVER["REQUEST_METHOD"] == "POST") {
		if(isset($_POST["username"]) && isset($_POST["password"])){
			$username = $_POST["username"];
			$password = $_POST["password"];
		} else {

		}
	} else {

	}

	$conn = null;

	try {
		$conn = db_connect();

		//valid student
		$validRes = validStudent($conn, $username, $password);

		if($validRes != null) {
			$feedback["result"] = "valid";
			$_SESSION["studentID"] = $validRes->StudentID;
			$_SESSION["studentUsername"] = $validRes->Username;
		} else {
			$feedback["result"] = "invalid";
		}
	} catch(Exception $e) {
		if($conn != null) {
			db_close($conn);
		}

		debug_err($e);
		$feedback["message"] = $e->getMessage();
		echo json_encode($feedback);
		exit;
	}

	db_close($conn);
	$feedback["message"] = "success";
	echo json_encode($feedback);
?>
