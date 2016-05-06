<?php	
	//if true, echo debug output in dev mode, else production mode
	$DEBUG_MODE = true;
    //session and import
	session_start();
    require_once("connection.php");
    if($DEBUG_MODE){
        echo "<script language=\"javascript\">  console.log(\"SUBMISSION.\"); </script>";
    }
    //assign userid and studentid
    if(isset($_SESSION['userid'])){
        $studentid = $_SESSION['userid'];
        $quizid = $_SESSION['quizid'];
        if($DEBUG_MODE){
            echo "<script language=\"javascript\">  console.log(\"This is DEBUG_MODE with SESSION studentid = ".$studentid." and quizid = ".$quizid.".\"); </script>";
        }
    }else{
        if(DEBUG_MODE){
            echo "<script language=\"javascript\">  console.log(\"This is DEBUG_MODE with hard-code studentID = 1 and quizID = 1.\"); </script>";
            $studentid = 1;
            $quizid = 1;
        }else{
            //todo: error handling
        }
    }
	
	if($_SERVER["REQUEST_METHOD"] == "POST"){
		
		$conn = db_connect();
		
		if(isset($_POST['MCQIDArr']) && isset($_POST['answerArr'])){
			$MCQIDArr = json_decode($_POST['MCQIDArr']);
			$answerArr = json_decode($_POST['answerArr']);			
			$feedbackArr = [];			
			$mcqGradeSql = "SELECT CorrectChoice
							FROM   MCQ_Question
							WHERE  MCQID = ?";			
			$mcqGradeQuery = $conn->prepare($mcqGradeSql);            
            $threshold = count($MCQIDArr)*0.2;
            $score = 0;
            //Calculate Score
            for($i=0; $i<count($MCQIDArr); $i++){
                $sql = $conn->prepare('SELECT COUNT(*) FROM MCQ_Question WHERE `MCQID` = BINARY :mcqid AND `CorrectChoice` = BINARY :correctchoice');
                $sql->bindParam(':mcqid', $MCQIDArr[$i]);
                $sql->bindParam(':correctchoice', $answerArr[$i]);
                $sql->execute();
                $score += $sql->fetchColumn();
            }		
            if($DEBUG_MODE){
                echo "<script language=\"javascript\">  console.log(\"Score: $score\"); </script>";
            }
            //UPDATE Quiz_Record
            if ($score >= $threshold) {
                //SQL UPDATE STATEMENT
                $update_stmt = "REPLACE INTO Quiz_Record(QuizID, StudentID)
                     VALUES (?,?);";			
                $update_stmt = $conn->prepare($update_stmt);                            
                if(! $update_stmt -> execute(array($quizid, $studentid))){
                    echo "<script language=\"javascript\">  alert(\"Error occurred to submit your answer. Report this bug to reseachers.\"); </script>";
                } else{ 
                    echo "<script language=\"javascript\">  console.log(\"Quiz Passed\"); </script>";
                }
            }else{
                //todo: if failed the quiz
            }
            
            //UPDATE MCQ_Question_Record
            for($i=0; $i<count($MCQIDArr); $i++){
                if(!isset($answerArr[$i])){
                    if ($score >= $threshold) {
                        //SQL UPDATE STATEMENT
                        $update_stmt = "REPLACE INTO MCQ_Question_Record(StudentID, MCQID, Choice)
                                     VALUES (?,?,?);";			
                        $update_stmt = $conn->prepare($update_stmt);                            
                        if(! $update_stmt -> execute(array($studentid, $MCQIDArr[$i], null))){
                            echo "<script language=\"javascript\">  alert(\"Error occurred to submit your answer. Report this bug to reseachers.\"); </script>";
                        }
                    } else{                                
                        
                    }
                } else{                    
                    if ($score >= $threshold) {
                        //SQL UPDATE STATEMENT
                        $update_stmt = "REPLACE INTO MCQ_Question_Record(StudentID, MCQID, Choice)
                                     VALUES (?,?,?);";			
                        $update_stmt = $conn->prepare($update_stmt);                            
                        if(! $update_stmt -> execute(array($studentid, $MCQIDArr[$i], $answerArr[$i]))){
                            echo "<script language=\"javascript\">  alert(\"Error occurred to submit your answer. Report this bug to reseachers.\"); </script>";
                        }
                    } else{
                        //DEMO CODE to check the if-else structure
                        /*
                        $update_stmt = "REPLACE INTO MCQ_Question_Record(StudentID, MCQID, Choice)
                                     VALUES (?,?,?);";			
                        $update_stmt = $conn->prepare($update_stmt);                            
                        if(! $update_stmt -> execute(array($studentid, $MCQIDArr[$i], "WRONG"))){
                            echo "<script language=\"javascript\">  alert(\"Error occurred to submit your answer. Report this bug to reseachers.\"); </script>";
                        }
                        */                        
                    }
                }                
            }
            
			
			echo "<script>";
            
			for($i=0; $i<count($MCQIDArr); $i++){
							
				$mcqGradeQuery->execute(array($MCQIDArr[$i]));	
				$mcqGradeRes = $mcqGradeQuery->fetch(PDO::FETCH_OBJ);
				
				$MCQContents = 'txt'.$MCQIDArr[$i];
				
				echo "
					
					var options = document.getElementsByName(\"".$MCQIDArr[$i]."\");
					
					var contents = document.getElementsByName(\"".$MCQContents."\");
					
					for(j = 0; j < options.length; j++){ ";
						
					if(!isset($answerArr[$i])){
						echo "
							if(options[j].value == \"".$mcqGradeRes->CorrectChoice."\"){
								contents[j].style.background=\"#00ff00\";
							}
							";
							
					} else {							
							if($mcqGradeRes->CorrectChoice == $answerArr[$i]){
							
								echo "
										if(options[j].checked == true){
											contents[j].style.background=\"#00ff00\";
										}
									 ";
									 
							} else {
							
								echo "
										if(options[j].checked == true){
											contents[j].style.background=\"#ff0000\";
										}
							
										if(options[j].value == \"".$mcqGradeRes->CorrectChoice."\"){
											contents[j].style.background=\"#00ff00\";
										}
									";
							}	
						}
						
					echo "}";	
			}
			
			echo "</script>";
					
				
		}
	}

?>