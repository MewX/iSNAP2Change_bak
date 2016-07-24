<?php
    require_once("../mysql-lib.php");
    require_once("../debug.php");
    $pageName = "save-due-time";


    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if(isset($_POST["student_id"]) && isset($_POST["week"]) && isset($_POST["due_time"])){
            $studentID = $_POST["student_id"];
            $week = $_POST["week"];
            $dueTime = $_POST["due_time"];
        } else {

        }
    } else {

    }

    $feedback = array();
    $conn = null;

    try {
        $conn = db_connect();

        createStuWeekRecord($conn, $studentID, $week, $dueTime);
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