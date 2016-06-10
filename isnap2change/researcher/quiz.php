<?php
    /**
    TODO: 
    edit quiz (jump to different editor)
    */
    session_start();
    require_once("../mysql-lib.php");
    require_once("../debug.php");
    require_once("/researcher-validation.php");
    $pageName = "quiz";
    $columnName = array('QuizID','Week','QuizType','TopicName','Points');
    // list all editable quiz types    
    $quizTypeArray = array('MCQ','SAQ','Matching','Poster');
    
    try{   	    
        $conn = db_connect();
        if($_SERVER["REQUEST_METHOD"] == "POST"){
            if(isset($_POST['update'])){                          
                $update = $_POST['update'];
                if($update == 1){
                    try{
                        $week = $_POST['week'];
                        $quizType = $_POST['quiztype'];
                        $topicName = $_POST['topicname'];
                        
                        $conn->beginTransaction();              
                        
                        //insert and get topicID
                        $topicResult = getTopicByName($conn, $topicName);  
                        $topicID = $topicResult->TopicID;                        
                        $quizID = createQuiz($conn, $topicID, $quizType, $week); 
                        //if MCQ, insert MCQ_Section
                        if($quizType=='MCQ'){                        
                            $points = 0;
                            $questionnaires = 0;
                            createMCQSection($conn, $quizID, $points, $questionnaires);
                        } else {
                            /* TODO */
                        }     
                        createEmptyLearningMaterial($conn, $quizID);
                        
                        $conn->commit();                    
                    } catch(Exception $e) {
                        debug_err($pageName, $e);
                        $conn->rollback();
                    }                
                }
                else if($update == -1){                      
                    $quizID = $_POST['quizid'];
                    deleteQuiz($conn, $quizID);
                }            
            }
        } 
    } catch(Exception $e) {
        debug_err($pageName, $e);
    }     
    
    
    try{    
        if(isset($_GET['week'])){
            $quizResult = getQuizzesByWeek($conn, $_GET['week']);
        }else{
            $quizResult = getQuizzes($conn);
        } 
        $topicResult = getTopics($conn); 
    } catch(Exception $e) {
        debug_err($pageName, $e);
    }  
    
    db_close($conn);      
    
?>
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>iSNAP2Change Admin</title>

    <!-- Bootstrap Core CSS -->
    <link href="../bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- MetisMenu CSS -->
    <link href="../bower_components/metisMenu/dist/metisMenu.min.css" rel="stylesheet">

    <!-- DataTables CSS -->
    <link href="../bower_components/datatables-plugins/integration/bootstrap/3/dataTables.bootstrap.css" rel="stylesheet">

    <!-- DataTables Responsive CSS -->
    <!-- <link href="../bower_components/datatables-responsive/css/dataTables.responsive.css" rel="stylesheet"> -->

    <!-- Custom CSS -->
    <link href="../dist/css/sb-admin-2.css" rel="stylesheet">

    <!-- Custom Fonts -->
    <link href="../bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

    <!--w3data.js to include html-->
    <script src="../js/w3data.js"></script>
    
    <style>
    .glyphicon:hover {
        background-color: rgb(153, 153, 102);
    }
    </style>
</head>

<body>

    <div id="wrapper">
        <div w3-include-html="navigation.html"></div> 
        <div id="page-wrapper">
            <div class="row">
                <div class="col-lg-12">                
                    <h1 class="page-header">Quiz Overview 
                    <?php if(isset($_GET['week'])) { ?>
                        <div class="alert alert-info alert-dismissable" style="display: inline-block;">
                            <button type="button" class="close" data-dismiss="alert" aria-hidden="true" onclick="location.href='quiz.php';" >×</button>
                            <i class="fa fa-info-circle"></i>  <?php echo 'Week '.$_GET['week'];  ?> 
                        </div>                    
                    <?php } ?>
                    </h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Quiz Information Table <span class="glyphicon glyphicon-plus pull-right" data-toggle="modal" data-target="#dialog"></span>
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="dataTable_wrapper">
                                <table class="table table-striped table-bordered table-hover" id="datatables">
                                    <thead>
                                        <tr>
                                        <?php for($i=0; $i<count($columnName); $i++) {
                                            if ($i==0){?>
                                            <th style="display:none"><?php echo $columnName[$i]; ?></th>
                                            <?php } else {?>                                            
                                            <th><?php echo $columnName[$i]; ?></th>
                                        <?php }
                                        }?>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <?php for($i=0; $i<count($quizResult); $i++) {?>
                                        <tr class="<?php if($i % 2 == 0){echo "odd";} else {echo "even";} ?>">
                                            <td style="display:none"><?php echo $quizResult[$i]->QuizID ?></td>
                                            <td><?php echo $quizResult[$i]->Week ?></td>
                                            <td><?php if($quizResult[$i]->QuizType=='MCQ') {echo 'Multiple Choice';} else if($quizResult[$i]->QuizType=='SAQ') {echo 'Short Answer';} else {echo $quizResult[$i]->QuizType;} ?></a></td>
                                            <td><?php echo $quizResult[$i]->TopicName ?></td>
                                            <td><?php echo getQuizPoints($conn, $quizResult[$i]->QuizID); ?><span class="glyphicon glyphicon-remove pull-right" aria-hidden="true"></span><span class="pull-right" aria-hidden="true">&nbsp;</span><span class="glyphicon glyphicon-edit pull-right" aria-hidden="true"></span></td>
                                            <!---->
                                        </tr>
                                    <?php } ?>    
                                    </tbody>
                                </table>
                            </div>
                            <!-- /.table-responsive -->
                            <div class="well row">
                                <h4>Quiz Overview Notification</h4>
                                <div class="alert alert-info">
                                    <p>View quizzes by filtering or searching. You can create/update/delete any quiz.</p>
                                </div>
                                <div class="alert alert-danger">
                                    <p><strong>Warning</strong> : If you remove one quiz. All the <strong>questions and submission</strong> of this quiz will also get deleted (not recoverable).</p> It includes <strong>learning material, questions and options, their submissions and your grading/feedback</strong>, not only the quiz itself.
                                </div>
                            </div>
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->            
        </div>
        <!-- /#page-wrapper -->
    </div>
    <!-- /#wrapper -->
    <!-- Modal -->
      <div class="modal fade" id="dialog" role="dialog">
        <div class="modal-dialog">        
          <!-- Modal content-->
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal">&times;</button>
              <h4 class="modal-title" id="dialogTitle">Edit Class</h4>
            </div>
            <div class="modal-body">
            <form id="submission" method="post" action="<?php if(isset($_GET['week'])) echo $_SERVER['PHP_SELF'].'?week='.$_GET['week']; else echo $_SERVER['PHP_SELF']; ?>">
                <!--if 1, insert; else if -1 delete;-->
                <input type=hidden name="update" id="update" value="1" required></input>
                <label for="QuizID" style="display:none">QuizID</label>
                <input type="text" class="form-control dialoginput" id="QuizID" name="quizid" style="display:none"></input>
                <label for="Week">Week</label>
                <input type="text" class="form-control dialoginput" id="Week" name="week"  placeholder="Input Week Number" <?php if(isset($_GET['week'])) {$w=$_GET['week']; echo "value='".$w."'"; } ?> required></input> 
                <br>    
                <label for='QuizType'>QuizType</label>
                <select class="form-control dialoginput" id="QuizType" form="submission" name="quiztype" required>
                  <option value="" disabled selected>Select Quiz Type</option>
                  <?php for($i=0; $i<count($quizTypeArray); $i++) {?>                  
                  <option value="<?php echo $quizTypeArray[$i] ?>"><?php echo $quizTypeArray[$i] ?></option>
                  <?php } ?>
                </select>
                <br>   
                <label for='TopicName'>TopicName</label>
                <select class="form-control dialoginput" id="TopicName" form="submission" name="topicname" required>
                <option value="" disabled selected>Select Topic</option>
                  <?php for($j=0; $j<count($topicResult); $j++) {?>                  
                    <option value='<?php echo $topicResult[$j]->TopicName ?>'><?php echo $topicResult[$j]->TopicName ?></option>
                  <?php } ?>
                </select>
                <br>
            </form>
            </div>
            <div class="modal-footer">            
              <button type="button" id="btnSave" class="btn btn-default">Save</button>
              <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
          </div>          
        </div>
      </div>
      <input type=hidden name="keyword" id="keyword" value="<?php if(isset($_GET['week'])){ echo $_GET['week']; } ?>"></input>
    <!-- jQuery -->
    <script src="../bower_components/jquery/dist/jquery.min.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="../bower_components/bootstrap/dist/js/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="../bower_components/metisMenu/dist/metisMenu.min.js"></script>

    <!-- DataTables JavaScript -->
    <script src="../bower_components/datatables/media/js/jquery.dataTables.min.js"></script>
    <script src="../bower_components/datatables-plugins/integration/bootstrap/3/dataTables.bootstrap.min.js"></script>

    <!-- Custom Theme JavaScript -->
    <script src="../dist/js/sb-admin-2.js"></script>    
    
    <!--jQuery Validate plugin-->
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.15.0/jquery.validate.min.js"></script>

    <!-- Page-Level Scripts -->
    <script>
    //DO NOT put them in $(document).ready() since the table has multi pages
    $('.glyphicon-edit').on('click', function (){
        /*...*/        
    });
    $('.glyphicon-plus').on('click', function (){
        $('#dialogTitle').text("Add Quiz");
        $('#update').val(1);
        for(i=0;i<$('.dialoginput').length;i++){
            if(i!=1){
                $('.dialoginput').eq(i).val('');
            } else {
                <?php if(!isset($_GET['week'])){?>
                    $('.dialoginput').eq(i).val('');
                <?php } ?>
            }            
        }        
    }); 
    $('.glyphicon-remove').on('click', function (){
        if (confirm('[WARNING] Are you sure to remove this quiz? If you remove one quiz. All the questions and submission of this quiz will also get deleted (not recoverable). It includes learning material, questions and options, their submissions and your grading/feedback, not only the quiz itself.')) {
            $('#update').val(-1);
            for(i=0;i<$('.dialoginput').length;i++){                
                $('.dialoginput').eq(i).val($(this).parent().parent().children('td').eq(i).text().trim());
            }
            $('#submission').submit();
        }           
    });
    $('#btnSave').on('click', function (){
        $('#submission').validate({
          rules: {
            week: {
              required: true,
              digits: true
            }
          }
        });   
        $('#submission').submit();
    });
    //include html
    w3IncludeHTML();   
    $(document).ready(function() {
        var table = $('#datatables').DataTable({
                responsive: true,
                "initComplete": function(settings, json) {                    
                    $('.input-sm').eq(1).val($("#keyword").val().trim());                    
                },
                "order": [[ 1, "asc" ]],
                "pageLength":50,
                "aoColumnDefs": [
                  { "bSearchable": false, "aTargets": [ 0 ] }
                ]
        })
        //search keyword, exact match
        table.search(
            $("#keyword").val().trim(), true, false, true
        ).draw();     
    });        
    </script>
</body>

</html>
