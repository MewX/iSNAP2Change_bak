<?php 
    //if true, echo debug output in dev mode, else production mode
	$DEBUG_MODE = true;
    $NUM_OF_LEVEL[] = 5;
    if(!isset($_SESSION)) 
    { 
        session_start(); 
    }   
	require_once('mysql-lib.php');
    if ($_SERVER["REQUEST_METHOD"] == "GET") {        
        if(isset($_GET["command"]) && isset($_GET["gameid"])){
            $gameid = $_GET["gameid"];
            if($_GET["command"] == "retrieve" && $gameid == 1){
                if(isset($_SESSION['studentID'])){
                    $studentID = $_SESSION['studentID'];
                    echo "<script language=\"javascript\">  console.log(\"This is DEBUG_MODE with SESSION studentid = ".$studentID.".\"); </script>";
                    $scoreArray = retrieve_data(); 
                }else{
                    echo "<script language=\"javascript\">  console.log(\"You have not logged in.\"); </script>";
                    if($DEBUG_MODE) {
                        $studentID = 1;
                        echo "<script language=\"javascript\">  console.log(\"This is DEBUG_MODE with TEST studentid = ".$studentID.".\"); </script>";
                        $scoreArray = retrieve_data(); 
                    }                
                }
                echo "score array:".join(',', $scoreArray);
            }
        }
    }
    function retrieve_data()
    {
        global $NUM_OF_LEVEL, $gameid, $studentID;
        $conn = db_connect();                    
        for($i=1; $i<=$NUM_OF_LEVEL[0]; $i++){
            $retrieveScorePreSql = "SELECT COUNT(*) FROM Game_Record WHERE `GameID` = ? AND `StudentID` = ? AND `Level` = ?";
            $retrieveScorePreQuery = $conn->prepare($retrieveScorePreSql);
            $retrieveScorePreQuery->execute(array($gameid, $studentID, $i));
            if ($retrieveScorePreQuery->fetchColumn() > 0) {
                $retrieveScoreSql = "SELECT GameID,StudentID,`Level`,Score FROM Game_Record WHERE `GameID` = ? AND `StudentID` = ? AND `Level` = ?";
                $retrieveScoreQuery = $conn->prepare($retrieveScoreSql);
                $retrieveScoreQuery->execute(array($gameid, $studentID, $i));
                $retrieveScoreResult = $retrieveScoreQuery->fetch(PDO::FETCH_OBJ);
                echo "<script language=\"javascript\">  console.log(\"[SUCCESS] Game Record Found. gameid: $gameid  studentid: $studentID level: $i score:".$retrieveScoreResult->Score."\"); </script>";
                $scoreArray[] = $retrieveScoreResult->Score;
            }
            else {
                 echo "<script language=\"javascript\">  console.log(\"[INFO] No Game Record Found. gameid: $gameid  studentid: $studentID level: $i score:null(set to 0)\"); </script>";
                 $scoreArray[] = 0;
            }
        }
        db_close($conn);
        return $scoreArray;
    }
?>
