<?php
    //if true, echo debug output in dev mode, else production mode
	$DEBUG_MODE = true;    
	session_start();
    require_once("connection.php");	
    require_once("encrypt.php");      
    $conn = db_connect();
    
    //set userid    
    if(isset($_SESSION['studentid'])){
        $studentid = $_SESSION['studentid'];
        if($DEBUG_MODE){
            echo "<script language=\"javascript\">  console.log(\"This is DEBUG_MODE with SESSION studentID = ".$studentid.".\"); </script>";
        }
    }else{
        if($DEBUG_MODE){
            echo "<script language=\"javascript\">  console.log(\"This is DEBUG_MODE with hard-code studentID = 1.\"); </script>";
            $studentid = 1;
        }
    }
    //POST parameters
    if ($_SERVER["REQUEST_METHOD"] == "POST") {		
		if(isset($_POST["quizid"]) && isset($_POST["week"]) && isset($_POST["status"])){
			$quizid = $_POST["quizid"];
			$week = $_POST["week"];
			$status = $_POST["status"];
            //[unused] get learning-material
            $materialPreSql = "SELECT COUNT(*) 
                               FROM   Learning_Material
                               WHERE  QuizID = ?";							
            $materialPreQuery = $conn->prepare($materialPreSql);
            $materialPreQuery->execute(array($quizid));			
            if($materialPreQuery->fetchColumn() == 1){
                $materialSql = "SELECT Content, TopicName 
                                FROM   Learning_Material NATURAL JOIN Quiz
                                                         NATURAL JOIN Topic
                                WHERE  QuizID = ?";							
                $materialQuery = $conn->prepare($materialSql);
                $materialQuery->execute(array($quizid));
                $materialRes = $materialQuery->fetch(PDO::FETCH_OBJ);		
            } else {       
            }

            // get matching section
            $matchingSectionSql = "SELECT Explanation, Points, MultipleChoices
                       FROM   Matching_Section
                       WHERE  QuizID = ?";
            $matchingSectionQuery = $conn->prepare($matchingSectionSql);
            $matchingSectionQuery->execute(array($quizid));
            $matchingSectionResult = $matchingSectionQuery->fetch(PDO::FETCH_OBJ);
            $score=$matchingSectionResult->Points;
            // if 1, multipleChoices
            $multipleChoices=$matchingSectionResult->MultipleChoices;
            
            // get matching questions
            $matchingQuestionSql = "SELECT MatchingQuestionID, Question
                       FROM   Matching_Section NATURAL JOIN Matching_Question
                       WHERE  QuizID = ?
                       ORDER BY MatchingQuestionID";
            $matchingQuestionQuery = $conn->prepare($matchingQuestionSql);
            $matchingQuestionQuery->execute(array($quizid));
            $matchingQuestionResult = $matchingQuestionQuery->fetchAll(PDO::FETCH_OBJ);
            
            
            // get matching options
            $matchingOptionSql = "SELECT MatchingQuestionID, Explanation, Question, Content, Points
                       FROM   Matching_Section NATURAL JOIN Matching_Question NATURAL JOIN Matching_Option
                       WHERE  QuizID = ?
                       ORDER BY MatchingQuestionID";
            $matchingOptionQuery = $conn->prepare($matchingOptionSql);
            $matchingOptionQuery->execute(array($quizid));
            $matchingOptionResult = $matchingOptionQuery->fetchAll(PDO::FETCH_OBJ);
            
            //if submission            
            if($status == "GRADED"){
                $quizid = $_POST["quizid"];
                $update_stmt = "INSERT INTO Quiz_Record(QuizID, StudentID, `Status`, Score)
                                             VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE Score = ?";			
                $update_stmt = $conn->prepare($update_stmt);                
                if(! $update_stmt -> execute(array($quizid, $studentid, $status, $score, $score))){
                    echo "<script language=\"javascript\">  alert(\"Error occurred to update your score. Report this bug to reseachers.\"); </script>";
                }
            }
            //if Jump from weekly tasks/learning materials
            else if($status == "UNANSWERED"){
                if($DEBUG_MODE){
                    echo "<script language=\"javascript\">  console.log(\"Jump from weekly tasks/learning materials.\"); </script>";
                }        
            } else {
                //todo: error handling
            }       
        
        } else {
			
		}		
	} else {		
	}
    
    
    db_close($conn); 
    
?>


<!doctype html>
<html>
    <head>
    <meta charset='utf-8'>
    <!--dragula plugin css-->
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
    <link href='css/dragula.css' rel='stylesheet' type='text/css' />
    <!--    
    To edit style, please modify this css file    
    -->
    <link href='css/matching.css' rel='stylesheet' type='text/css' />
    <script type="text/javascript" src="js/jquery-1.12.3.js"></script>
    <!--md5-->
    <script src="js/md5.min.js"></script>
    <title>1:1 matching</title>
    <style>
    .parent { display: -ms-flex; display: -webkit-flex; display: flex; }
    .parent>div { flex:1; }
    .choices { display: -ms-flex; display: -webkit-flex; display: flex; flex-direction:column; }
    .choices>div { flex:1; text-align: center; }
    .rotated {
      -webkit-transform: rotate(180deg);     /* Chrome and other webkit browsers */
      -moz-transform: rotate(180deg);        /* FF */
      -o-transform: rotate(180deg);          /* Opera */
      -ms-transform: rotate(180deg);         /* IE9 */
      transform: rotate(180deg);             /* W3C compliant browsers */

      /* IE8 and below */
      filter: progid:DXImageTransform.Microsoft.Matrix(M11=-1, M12=0, M21=0, M22=-1, DX=0, DY=0, SizingMethod='auto expand');
    } 
    </style>
    </head>
    <body>
    <script>
    function goBack()
    {
        document.getElementById("goBack").submit();
    }
    
    function submitQuiz()
    {   
        var passed = true;
        var count = 0;
        $(".choice").each(function(){
            //match md5 values
            if($(this).attr('id') !=  md5(count++)) {
                passed = false;
            }
        });
        //passed/failed feedback
        if (passed) {            
            alert("Congratulations! You have finished this quiz.");
            $("#back-btn").text("GO BACK");
            $("#back-btn").attr("onclick", "goBack()");
            document.getElementById("submission").submit();
            }
        else {alert("Failed! Try again!")};        
    }    
    </script>        
    <header class="navbar navbar-static-top bs-docs-nav">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
            </button>
            <a class="navbar-brand" href="#"> Matching Quiz</a>
        </div>
        
        <!--Sumbit/Go Back Button-->
        <div class="nav navbar-nav navbar-btn navbar-right" style="margin-right:22px;">
            <form id="goBack" method=post action=weekly-task.php>
                <?php if($status == "GRADED"){ ?>
                <button id="back-btn" type="button" onclick="goBack()" class="btn btn-success">GO BACK</button>
                <?php } else { ?>
                <button id="back-btn" type="button" onclick="submitQuiz();" class="btn btn-success">SUBMIT</button>
                <?php } ?>                                        
                <input type=hidden name="week" value=<?php echo $week; ?>></input>
            </form>	
            
        </div>
        <div class="nav navbar-nav navbar-btn navbar-right" style="margin-right: 15px; font-size: x-large;">
            <div id="clock">
                    <span class="timer"></span>
            </div>
        </div>
    </header>
    <form id="submission" method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
        <input type=hidden name="week" value=<?php echo $week; ?> ></input>        
        <input type=hidden name="quizid" value=<?php echo $quizid; ?> ></input>
        <input type=hidden name="status" value="GRADED" ></input>
        <?php if($multipleChoices == 0){ ?>
        <div class='examples'>      
            <div class='wrapper'>   
                <label><?php echo $matchingSectionResult->Explanation ?></label>   
                <div class="row parent">        
                    <div class='container choices'>
                        <div class="choices">
                            <?php for($i=0; $i<count($matchingOptionResult); $i++) { ?>
                            <div class="parent">
                                <!--Questions and Arrows-->
                                <div><span><?php echo $matchingOptionResult[$i]->Question ?> </span></div><div><img class="rotated" src="img/arrow-19-64x64.png" width="25%"/></div>
                            </div>
                            <?php } ?>
                        </div>
                    </div> 
                    <div id='sortable' class='container choices'>
                        <?php                         
                        $randomOptionArray = range(0, count($matchingOptionResult)-1);
                        //shuffle options
                        if($status != "GRADED")
                            shuffle($randomOptionArray);
                        foreach ($randomOptionArray as $value) { ?>
                        <div class="choice" id="<?php echo encryptMD5($value) ?>" ><?php echo $matchingOptionResult[$value]->Content ?></div>
                         <?php } ?>
                    </div>       
                </div>
          </div>
        </div>
        <?php } else {?>
        <div class="examples">        
            <label><?php echo $matchingSectionResult->Explanation ?></label> 
          <div class="parent">   
            <div class="wrapper">
              <!--Multiple Buckets-->
                <?php for($i=0; $i<count($matchingQuestionResult); $i++) { ?>
                <div id="bucket-defaults<?php echo $i ?>" class="container bucket">
                    <?php echo $matchingQuestionResult[$i]->Question ?>
                </div>
                <?php } ?>                
            </div>            
          </div>
          <div id="option-defaults" class="container">
                <?php                         
                $randomOptionArray = range(0, count($matchingOptionResult)-1);
                //shuffle options
                if($status != "GRADED")
                    shuffle($randomOptionArray);
                foreach ($randomOptionArray as $value) { ?>
                <div class="choice" id="<?php echo encryptMD5($value) ?>" ><?php echo $matchingOptionResult[$value]->Content ?></div>
                <?php } ?>
           </div>
        </div>       
        <?php } ?>
    </form>    
    <!--dragula plugin js-->
    <script src='js/dragula.js'></script>    
    <script src='js/example.min.js'></script>
    </body>
</html>