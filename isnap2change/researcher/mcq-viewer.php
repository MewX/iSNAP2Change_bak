<?php
    session_start();
    require_once("../connection.php");
    require_once("../debug.php");
    require_once("/researcher-validation.php");
    require_once("/get-quiz-points.php");	    
    $conn = db_connect();
    $overviewName = "quiz";
    $columnName = array('QuizID','Week','TopicName','Points', 'Questions');     
    //edit/delete quiz
    if($_SERVER["REQUEST_METHOD"] == "POST"){
        if(isset($_POST['update'])){                          
            $update = $_POST['update'];
            //update
            if($update == 0){
                
            }
            else if($update == 1){  
                $quizID = $_POST['quizid'];
                $update_stmt = "DELETE FROM Quiz WHERE QuizID = ?";			
                $update_stmt = $conn->prepare($update_stmt);
                if(! $update_stmt -> execute(array($quizID))){
                    echo "<script language=\"javascript\">  alert(\"Error occurred to delete quiz. Contact with developers.\"); </script>";
                } else{
                } 
            }            
        }
    }
    
    /**
    //learning-material-editor
    if(isset($_POST['richcontenttextarea'])){
    $conn = db_connect();
    $content = $_POST['richcontenttextarea'];
    $materialid = 1;   
    $quizid = 1;
    echo "<h2>Preview</h2>";       
    echo $content;
    
    $update_stmt = "REPLACE INTO Learning_Material(MaterialID,Content,QuizID)
                 VALUES (?,?,?);";			
    $update_stmt = $conn->prepare($update_stmt);                            
    if(! $update_stmt -> execute(array($materialid, $content, $quizid))){
        echo "<script language=\"javascript\">  alert(\"Error occurred to submit learning material. Report this bug to reseachers.\"); </script>";
    } else{            
        echo "<script language=\"javascript\">  console.log(\"Learning Material Submitted. materialid: $materialid  quizid: $quizid\"); </script>";
    }  
    */
    
    if($_SERVER["REQUEST_METHOD"] == "GET"){
        if(isset($_GET['quizid'])){
        $quizID = $_GET['quizid'];    
        // get quiz and topic
        $quizSql = "SELECT QuizID, Week, TopicName, COUNT(*) AS Questions
                   FROM Quiz NATURAL JOIN Topic NATURAL JOIN MCQ_Section NATURAL JOIN MCQ_Question WHERE QuizID = ?";
        $quizQuery = $conn->prepare($quizSql);
        $quizQuery->execute(array($quizID));
        $quizResult = $quizQuery->fetch(PDO::FETCH_OBJ); 
        }
        //get topic
        $topicSql = "SELECT TopicID, TopicName FROM Topic ORDER BY TopicID";
        $topicQuery = $conn->prepare($topicSql);
        $topicQuery->execute(array());
        $topicResult = $topicQuery->fetchAll(PDO::FETCH_OBJ); 
        
        $materialPreSql = "SELECT COUNT(*) 
					   FROM   Learning_Material
					   WHERE  QuizID = ?";							
        $materialPreQuery = $conn->prepare($materialPreSql);
        $materialPreQuery->execute(array($quizID));                
        if($materialPreQuery->fetchColumn() != 1){
                    
        }                
        $materialSql = "SELECT Content, TopicName 
                        FROM   Learning_Material NATURAL JOIN Quiz
                                                 NATURAL JOIN Topic
                        WHERE  QuizID = ?";
                                
        $materialQuery = $conn->prepare($materialSql);
        $materialQuery->execute(array($quizID));
        $materialRes = $materialQuery->fetch(PDO::FETCH_OBJ);

        //get questions and options
        $mcqSql = "SELECT MCQID, Question, CorrectChoice, Content, Explanation
				   FROM   MCQ_Section NATURAL JOIN MCQ_Question
								  NATURAL JOIN `Option`
			       WHERE  QuizID = ?
			       ORDER BY MCQID";
								
		$mcqQuery = $conn->prepare($mcqSql);
		$mcqQuery->execute(array($quizID));
        $mcqResult = $mcqQuery->fetchAll(PDO::FETCH_OBJ); 


        //get max option num        
        $optionNumSql = "SELECT MAX(OptionNum) AS MaxOptionNum FROM (SELECT COUNT(*) AS OptionNum FROM MCQ_Question natural JOIN `Option` WHERE QuizID = ? GROUP BY MCQID) AS OptionNumbTable;";								
		$optionNumQuery = $conn->prepare($optionNumSql);
		$optionNumQuery->execute(array($quizID));
        $optionNumResult = $optionNumQuery->fetch(PDO::FETCH_OBJ);
        /**
        $mcqQuesColName[] = 'QuizID';
        $mcqQuesColName[] = 'Question';
        for($i=0; $i<$optionNumResult->MaxOptionNum; $i++) {
            $mcqQuesColName[] = 'Option'.($i+1);
        }
        */
        $mcqQuesColName = array('MCQID','Question','Option', 'Explanation','Edit');
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
    <script src="//cdn.tinymce.com/4/tinymce.min.js"></script>
    <script>
      /**
      tinymce.init({
      selector: 'textarea',
      height: 500,
      theme: 'modern',
      plugins: [
        'advlist autolink lists link image charmap print preview hr anchor pagebreak',
        'searchreplace wordcount visualblocks visualchars code fullscreen',
        'insertdatetime media nonbreaking save table contextmenu directionality',
        'emoticons template paste textcolor colorpicker textpattern imagetools'
      ],
      toolbar1: 'insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
      toolbar2: 'print preview media | forecolor backcolor emoticons',
      image_advtab: true,
      templates: [
        { title: 'Test template 1', content: 'Test 1' },
        { title: 'Test template 2', content: 'Test 2' }
      ],
      content_css: [
        '//fast.fonts.net/cssapi/e6dc9b99-64fe-4292-ad98-6974f93cd2a2.css',
        '//www.tinymce.com/css/codepen.min.css'
      ]
     });
     */
    </script>
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
                    <h1 class="page-header">Multiple Choice Quiz Editor</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-12">
                    
                    <!--MetaData-->
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Quiz MetaData
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <form id="submission" method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
                                <!--if 0 update; else if -1 delete;-->
                                <input type=hidden name="update" id="update" value="1"></input>                
                            <?php for($i=0; $i<count($columnName); $i++) {
                                    if($columnName[$i]!='TopicName'){ ?>
                                    <label for='<?php echo $columnName[$i]; ?>' <?php if ($i==0){ echo 'style="display:none"';} ?>><?php echo $columnName[$i]; ?></label>    
                                    <input type="text" class="form-control metadatainput" id="<?php echo $columnName[$i]; ?>" name="<?php echo strtolower($columnName[$i]); ?>"  
                                    <?php if ($i==0){ echo 'style="display:none"';} ?> value="<?php if($i!=3) {echo $quizResult->$columnName[$i];} else  {echo getQuizPoints($quizResult->QuizID);} ?>" required></input>
                                <?php }
                                else {?>
                                    <label for='<?php echo $columnName[$i]; ?>' <?php if ($i==0){ echo 'style="display:none"';} ?>><?php echo $columnName[$i]; ?></label>
                                    <select class="form-control metadatainput" id="<?php echo $columnName[$i]; ?>" form="submission" name="<?php echo strtolower($columnName[$i]);?>" required>
                                      <?php for($j=0; $j<count($topicResult); $j++) {?>                  
                                        <option value='<?php echo $topicResult[$j]->TopicName ?>' <?php if($topicResult[$j]->TopicName == $quizResult->$columnName[$i])echo 'selected' ?>><?php echo $topicResult[$j]->TopicName ?></option>
                                      <?php } ?>
                                    </select>                                     
                                <?php } 
                            }?>
                                <br>
                            </form>
                            <!--edit metadata-->
                            <span class="glyphicon glyphicon-remove pull-right" aria-hidden="true"></span><span class="pull-right" aria-hidden="true">&nbsp;</span><span class="glyphicon glyphicon-edit pull-right" data-toggle="modal" data-target="#dialog" aria-hidden="true"></span>    
                        </div>                            
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                    
                    
                    <!--Learning Material-->
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Learning Material 
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="heading" style="color: black; max-height:10vh; text-align:center; border-bottom: 1px solid #eee;">
                                <h1 style='padding: 0px;'> 
								<i>	<?php echo $materialRes->TopicName; ?> </i>                          
                                </h1> 
                            </div>
                   
                            <div class="para" style="padding-left:15px; padding-right:15px; padding-top:8px; text-align:center;">
                                <div style="color:black; justify-content:center; align-items:center;">
                                <i>
                                  <?php echo $materialRes->Content; ?></i>
                                </div>
                            </div>                        
                        
                            <span class="glyphicon glyphicon-remove pull-right" aria-hidden="true"></span><span class="pull-right" aria-hidden="true">&nbsp;</span><a href="learning-material-editor.php?quizid=<?php echo $quizResult->QuizID ?>"><span class="glyphicon glyphicon-edit pull-right" aria-hidden="true"></span></a>
                            <!-- data-toggle="modal" data-target="#dialog" -->                            
                        </div>                            
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                    
                    <!-- Options -->
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Questions and Options 
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="dataTable_wrapper">
                                <table class="table table-striped table-bordered table-hover" id="datatables">
                                    <thead>
                                        <tr>
                                        <?php for($i=0; $i<count($mcqQuesColName); $i++) {
                                            if ($i==0){?>
                                            <th style="display:none"><?php echo $mcqQuesColName[$i]; ?></th>
                                            <?php } else {?>                                            
                                            <th><?php echo $mcqQuesColName[$i]; ?></th>
                                        <?php }
                                        }?>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php for($i=0; $i<count($mcqResult); $i++) {?>
                                        <tr class="<?php if($i % 2 == 0){echo "odd";} else {echo "even";} ?>">
                                            <td style="display:none"><?php echo $mcqResult[$i]->$mcqQuesColName[0]; ?></td>
                                            <td><?php echo $mcqResult[$i]->$mcqQuesColName[1] ?></td>
                                            <td class ="<?php if ($mcqResult[$i]->Content == $mcqResult[$i]->CorrectChoice) {echo 'bg-success';} else {echo 'bg-danger';} ?>">
                                                <?php echo $mcqResult[$i]->Content; ?>
                                            <td><?php echo $mcqResult[$i]->$mcqQuesColName[3] ?></td>
                                            <td><span class="glyphicon glyphicon-remove pull-right " aria-hidden="true"></span><span class="pull-right" aria-hidden="true">&nbsp;</span><span class="glyphicon glyphicon-edit pull-right" data-toggle="modal" data-target="#dialog" aria-hidden="true"></span></td>            
                                        </tr>
                                    <?php } ?>
                                    </tbody>
                                </table>
                            </div>
                            <!-- /.table-responsive -->
                            <div class="well row">
                                <h4>Multiple Choice Quiz Overview Notification</h4>
                                <div class="alert alert-info">
                                    <p>View quizzes by filtering or searching. You can create/update/delete any class.</p>
                                </div>
                                <div class="alert alert-danger">
                                    <p><strong>Warning</strong> : If you remove one quiz. All the <strong>questions and submission</strong> of this quiz will also get deleted (not recoverable).</p> It includes <strong>learning material, questions and options, their submissions and your grading/feedback</strong>, not only the quiz itself.
                                </div>
                            </div>
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    
                    
                    
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
              <h4 class="modal-title" id="dialogTitle">Edit Question</h4>
            </div>
            <div class="modal-body">
            <form id="submission" method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
                <!--if 1, insert; else if 0 update; else if -1 delete;-->
                <input type=hidden name="update" id="update" value="1"></input>
                <label for="<?php echo $mcqQuesColName[0]; ?>" style="display:none"><?php echo $mcqQuesColName[0]; ?></label>
                <input type="text" class="form-control dialoginput" id="<?php echo $mcqQuesColName[0]; ?>" name="<?php echo strtolower($mcqQuesColName[0]); ?>" style="display:none">
                <br><label for="<?php echo $mcqQuesColName[1]; ?>"><?php echo $mcqQuesColName[1]; ?></label>
                <input type="text" class="form-control dialoginput" id="<?php echo $mcqQuesColName[1]; ?>" name="<?php echo strtolower($mcqQuesColName[1]); ?>" required><br>
                <table id="tblAppendGrid"></table>
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

    <!-- DataTables rowsGroup Plugin -->
    <script src="../bower_components/datatables-plugins/rowsgroup/dataTables.rowsGroup.js "></script>
    
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.11.4/themes/ui-lightness/jquery-ui.css" />
    <link rel="stylesheet" href="https://code.jquery.com/qunit/qunit-1.18.0.css" />
    <link href="../bower_components/appendgrid/jquery.appendGrid-1.6.2.css" rel="stylesheet" />
    <script type="text/javascript" src="https://code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../bower_components/appendgrid/jquery.appendGrid-1.6.2.js"></script>   
    
    <!-- Page-Level Scripts -->
    <script>
    //DO NOT put them in $(document).ready() since the table has multi pages
    $('.glyphicon-edit').on('click', function (){
        $('#dialogTitle').text("Edit Question");
        $('#update').val(0);
        for(i=0;i<$('.dialoginput').length;i++){                
            $('.dialoginput').eq(i).val($(this).parent().parent().children('td').eq(i).text());
        }
        //disable MCQID    
        $('.dialoginput').eq(0).attr('disabled','disabled');        
    });
    $('.glyphicon-plus').on('click', function (){
        $('#dialogTitle').text("Add Question");
        $('#update').val(1);
        for(i=0;i<$('.dialoginput').length;i++){                
            $('.dialoginput').eq(i).val('');
        }
        //disable MCQID
        $('.dialoginput').eq(0).attr('disabled','disabled');         
    }); 
    $('.glyphicon-remove').on('click', function (){
        if (confirm('[WARNING] Are you sure to remove this class? All the quiz data in this class will also get deleted (not recoverable). It includes quiz information, their submissions of every task and your grading/feedback, not only the class itself.')) {
            $('#update').val(-1);
            //fill required input
            $('.dialoginput').eq(0).prop('disabled',false);
            for(i=0;i<$('.dialoginput').length;i++){                
                $('.dialoginput').eq(i).val($(this).parent().parent().children('td').eq(i).text());
            }
            $('#submission').submit();
        }           
    });
    $('#btnSave').on('click', function (){
        $('#submission').validate();        
        //enable ClassID and EnrolledQuizs
        $('.dialoginput').eq(0).prop('disabled',false);
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
            //rows group for MCQID, Question and edit box
            rowsGroup: [1,4],
            "pageLength":100
        })
        //search keyword (schoolname), exact match
        table.search(
            $("#keyword").val().trim(), true, false, true
        ).draw();
         $('.metadatainput').eq(4).attr('disabled','disabled'); 
        
    });        
    </script>
    <script type="text/javascript">
        // Prepare common variables
        var gColumns = [
            { name: 'OptionID', type: 'hidden' },
            { name: 'Album', display: 'Album', type: 'text', ctrlAttr: { maxlength: 100 }, ctrlCss: { width: '160px' } },
            { name: 'Artist', display: 'Artist', type: 'text', ctrlAttr: { maxlength: 100 }, ctrlCss: { width: '120px' } },
            { name: 'Year', display: 'Year', type: 'text', ctrlAttr: { maxlength: 4 }, ctrlCss: { width: '50px' } },
            { name: 'Origin', display: 'Origin', type: 'select', ctrlOptions: { 0: '{Choose}', 1: 'Hong Kong', 2: 'Taiwan', 3: 'Japan', 4: 'Korea', 5: 'US', 6: 'Others' } },
            { name: 'CorrentChoice', display: 'CorrentChoice', type: 'checkbox' },
        ], gData = [
            { 'ID': 1, 'Album': 'Dearest', 'Artist': 'Theresa Fu', 'Year': '2009', 'Origin': 1, 'Poster': true, 'Price': 168.9 },
            { 'ID': 2, 'Album': 'To be Free', 'Artist': 'Arashi', 'Year': '2010', 'Origin': 3, 'Poster': true, 'Price': 152.6 },
            { 'ID': 3, 'Album': 'Count On Me', 'Artist': 'Show Luo', 'Year': '2012', 'Origin': 2, 'Poster': false, 'Price': 306.8 },
            { 'ID': 4, 'Album': 'Wonder Party', 'Artist': 'Wonder Girls', 'Year': '2012', 'Origin': 4, 'Poster': true, 'Price': 108.6 },
            { 'ID': 5, 'Album': 'Reflection', 'Artist': 'Kelly Chen', 'Year': '2013', 'Origin': 1, 'Poster': false, 'Price': 138.2 }
        ], gI18n = {
            append: '!append!',
            removeLast: '!removeLast!',
            insert: '!insert!',
            remove: '!remove!',
            moveUp: '!moveUp!',
            moveDown: '!moveDown!',
            rowDrag: '!rowDrag!',
            rowEmpty: '!rowEmpty!'
        }, gButtonClasses = {
            append: 'ap-pend',
            removeLast: 'remove-Last',
            insert: 'in-sert',
            remove: 're-move',
            moveUp: 'move-Up',
            moveDown: 'move-Down',
            rowDrag: 'row-Drag'
        }, gSectionClasses = {
			caption: 'cap-tion',
			header: 'head-er',
			body: 'bo-dy',
			footer: 'foot-er'
		};
        var eValid = false, eValues, eInitRows = 2, eDataLoaded = false, eCaption = 'Options', eIdPrefix = 'option';
        var $grid = $('#tblAppendGrid');
        $grid.appendGrid({
                caption: eCaption,
                captionTooltip: eCaption,
                columns: gColumns,
                initRows: eInitRows,
                idPrefix: eIdPrefix,
                i18n: gI18n,
                buttonClasses: gButtonClasses,
				sectionClasses: gSectionClasses,
                dataLoaded: function () {
                    eDataLoaded = true;
                }
        });
    </script>
    
    
</body>

</html>
