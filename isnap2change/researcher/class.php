<?php
session_start();
require_once("../mysql-lib.php");
require_once("../debug.php");
require_once("researcher-validation.php");
$pageName = "class";

//if insert/update/remove class
try {
    $conn = db_connect();
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_POST['update'])) {
            $update = $_POST['update'];
            if ($update == 1) {
                $className = $_POST['className'];
                $schoolName = $_POST['schoolName'];
                $teacherToken = $_POST['teacherToken'];
                $studentToken = $_POST['studentToken'];
                $schoolID = getSchoolByName($conn, $schoolName)->SchoolID;
                $classID = createClass($conn, $schoolID, $className);
                updateToken($conn, $classID, $teacherToken, "TEACHER");
                updateToken($conn, $classID, $studentToken, "STUDENT");
            } else if ($update == 0) {
                $classID = $_POST['classID'];
                $className = $_POST['className'];
                $schoolName = $_POST['schoolName'];
                $teacherToken = $_POST['teacherToken'];
                $studentToken = $_POST['studentToken'];
                $unlockedProgress = $_POST['unlockedProgress'];

                $schoolID = getSchoolByName($conn, $schoolName)->SchoolID;
                updateClass($conn, $classID, $schoolID, $className, $unlockedProgress);
                updateToken($conn, $classID, $teacherToken, "TEACHER");
                updateToken($conn, $classID, $studentToken, "STUDENT");
            } else if ($update == -1) {
                $classID = $_POST['classID'];
                deleteClass($conn, $classID);
            }
        }
    }
} catch (Exception $e) {
    debug_err($pageName, $e);
}

try {
    $weekResult = getMaxWeek($conn);
    $schoolResult = getSchools($conn);
    $classResult = getClasses($conn);
    $tokenResult = getTokens($conn);
    $studentNumResult = getStudentNum($conn);
} catch (Exception $e) {
    debug_err($pageName, $e);
}

db_close($conn);
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Header Library -->
    <?php require_once('header-lib.php'); ?>
</head>

<body>

<div id="wrapper">

    <?php require_once('navigation.php'); ?>

    <div id="page-wrapper">
        <div class="row">
            <div class="col-lg-12">
                <h1 class="page-header">Class Overview</h1>
            </div>
            <!-- /.col-lg-12 -->
        </div>
        <!-- /.row -->
        <div class="row">
            <div class="col-lg-12">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        Class Information Table <span class="glyphicon glyphicon-plus pull-right" data-toggle="modal"
                                                      data-target="#dialog"></span>
                    </div>
                    <!-- /.panel-heading -->
                    <div class="panel-body">
                        <div class="dataTable_wrapper">
                            <table class="table table-striped table-bordered table-hover" id="datatables">
                                <thead>
                                <tr>
                                    <th style="display:none">ClassID</th>
                                    <th>ClassName</th>
                                    <th>SchoolName</th>
                                    <th>TeacherToken</th>
                                    <th>StudentToken</th>
                                    <th>EnrolledStudents</th>
                                    <th>UnlockedProgress</th>
                                </tr>
                                </thead>
                                <tbody>
                                <?php for ($i = 0; $i < count($classResult); $i++) { ?>
                                    <tr class="<?php if ($i % 2 == 0) {
                                        echo "odd";
                                    } else {
                                        echo "even";
                                    } ?>">
                                        <td style="display:none"><?php echo $classResult[$i]->ClassID ?></td>
                                        <td>
                                            <a href="student.php?classID=<?php echo $classResult[$i]->ClassID ?>"><?php echo $classResult[$i]->ClassName ?></a>
                                        </td>
                                        <td><?php echo $classResult[$i]->SchoolName ?></td>
                                        <td><?php for ($j = 0; $j < count($tokenResult); $j++) {
                                                if ($tokenResult[$j]->ClassID == $classResult[$i]->ClassID && $tokenResult[$j]->Type == 'TEACHER') echo $tokenResult[$j]->TokenString;
                                            } ?></td>
                                        <td><?php for ($j = 0; $j < count($tokenResult); $j++) {
                                                if ($tokenResult[$j]->ClassID == $classResult[$i]->ClassID && $tokenResult[$j]->Type == 'STUDENT') echo $tokenResult[$j]->TokenString;
                                            } ?></td>
                                        <td><?php $count = 0;
                                            for ($j = 0; $j < count($studentNumResult); $j++) {
                                                if ($studentNumResult[$j]->ClassID == $classResult[$i]->ClassID) $count = $studentNumResult[$j]->Count;
                                            }
                                            echo $count; ?></td>
                                        <td><?php echo min($classResult[$i]->UnlockedProgress, $weekResult->WeekNum) . "/" . $weekResult->WeekNum ?>
                                            <span class="glyphicon glyphicon-remove pull-right"
                                                  aria-hidden="true"></span><span class="pull-right" aria-hidden="true">&nbsp;</span><span
                                                class="glyphicon glyphicon-edit pull-right" data-toggle="modal"
                                                data-target="#dialog" aria-hidden="true"></span></td>
                                    </tr>
                                <?php } ?>
                                </tbody>
                            </table>
                        </div>
                        <!-- /.table-responsive -->
                        <div class="well row">
                            <h4>Class Overview Notification</h4>
                            <div class="alert alert-info">
                                <p>View classes by filtering or searching. You can create/update/delete any class.</p>
                            </div>
                            <div class="alert alert-danger">
                                <p><strong>Warning</strong> : If you remove one class. All the <strong>student
                                        data</strong> in this class will also get deleted (not recoverable).</p> It
                                includes <strong>student information, their submissions of every task and your
                                    grading/feedback</strong>, not only the class itself.
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
                <form id="submission" method="post"
                      action="<?php if (isset($_GET['schoolID'])) echo $_SERVER['PHP_SELF'] . '?schoolID=' . $_GET['schoolID']; else echo $_SERVER['PHP_SELF']; ?>">
                    <!--if 1, insert; else if 0 update; else if -1 delete;-->
                    <input type=hidden name="update" id="update" value="1" required>
                    <label for="ClassID" style="display:none">ClassID</label>
                    <input type="text" class="form-control dialoginput" id="ClassID" name="classID"
                           style="display:none">
                    <br><label for="ClassName">ClassName</label>
                    <input type="text" class="form-control dialoginput" id="ClassName" name="className" required>
                    <br><label for="SchoolName">SchoolName</label>
                    <select class="form-control dialoginput" id="SchoolName" form="submission" name="schoolName"
                            required>
                        <?php for ($i = 0; $i < count($schoolResult); $i++) { ?>
                            <option
                                value="<?php echo $schoolResult[$i]->SchoolName ?>"><?php echo $schoolResult[$i]->SchoolName ?></option>
                        <?php } ?>
                    </select>
                    <br><label for="TeacherToken">TeacherToken</label><span
                        class="glyphicon glyphicon-random pull-right"></span>
                    <input type="text" class="form-control dialoginput" id="TeacherToken" name="teacherToken" required>
                    <br><label for="StudentToken">StudentToken</label><span
                        class="glyphicon glyphicon-random pull-right"></span>
                    <input type="text" class="form-control dialoginput" id="StudentToken" name="studentToken" required>
                    <br>
                    <label for="EnrolledStudents">EnrolledStudents</label>
                    <input type="text" class="form-control dialoginput" id="EnrolledStudents" name="enrolledstudents">
                    <br>
                    <label for="UnlockedProgress">UnlockedProgress</label>
                    <input type="text" class="dialoginput pull-right" id="textInput" value="" disabled>
                    <input type="range" class="dialoginput" min="0"
                           max="<?php echo min($classResult[$i]->UnlockedProgress, $weekResult->WeekNum) ?>"
                           id="UnlockedProgress" name="unlockedProgress" onchange="updateTextInput(this.value);">
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" id="btnSave" class="btn btn-default">Save</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
<input type=hidden name="keyword" id="keyword" value="
      <?php
if (isset($_GET['schoolID'])) {
    try {
        $schoolID = $_GET['schoolID'];
        $schoolResult = getSchool($conn, $schoolID);
        echo $schoolResult->SchoolName;
    } catch (Exception $e) {
        debug_err($pageName, $e);
        echo '';
    }
} else
    echo '';
?>">

<!-- SB Admin Library -->
<?php require_once('sb-admin-lib.php'); ?>
<!-- Page-Level Scripts -->
<script>
    function randomString(length) {
        return Math.round((Math.pow(36, length + 1) - Math.random() * Math.pow(36, length))).toString(36).slice(1);
    }
    //DO NOT put them in $(document).ready() since the table has multi pages

    var dialogInputArr = $('.dialoginput');
    $('.glyphicon-edit').on('click', function () {
        $('#dialogTitle').text("Edit Class");
        $('#update').val(0);
        for (i = 0; i < dialogInputArr.length - 2; i++) {
            dialogInputArr.eq(i).val($(this).parent().parent().children('td').eq(i).text().trim());
        }
        var currentWeek = $(this).parent().parent().children('td').eq(6).text().trim().split("/")[0];
        dialogInputArr.eq(6).val(currentWeek);
        dialogInputArr.eq(7).val(currentWeek);
        //disable ClassID, EnrolledStudents, UnlockedProgress
        dialogInputArr.eq(0).attr('disabled', 'disabled');
        dialogInputArr.eq(5).attr('disabled', 'disabled');
    });
    $('.glyphicon-plus').on('click', function () {
        $('#dialogTitle').text("Add Class");
        $('#update').val(1);
        for (i = 0; i < dialogInputArr.length; i++) {
            dialogInputArr.eq(i).val('');
        }
        //disable ClassID, EnrolledStudents, UnlockedProgress
        dialogInputArr.eq(0).attr('disabled', 'disabled');
        dialogInputArr.eq(5).attr('disabled', 'disabled');
    });
    $('.glyphicon-remove').on('click', function () {
        if (confirm('[WARNING] Are you sure to remove this class? All the student data in this class will also get deleted (not recoverable). It includes student information, their submissions of every task and your grading/feedback, not only the class itself.')) {
            $('#update').val(-1);
            //fill required input
            dialogInputArr.eq(0).prop('disabled', false);
            for (i = 0; i < dialogInputArr.length - 2; i++) {
                dialogInputArr.eq(i).val($(this).parent().parent().children('td').eq(i).text().trim());
            }
            var currentWeek = $(this).parent().parent().children('td').eq(6).text().trim().split("/")[0];
            dialogInputArr.eq(6).val(currentWeek);
            dialogInputArr.eq(7).val(currentWeek);
            $('#submission').submit();
        }
    });
    $('.glyphicon-random').on('click', function () {
        var index = $(this).index();
        if (index == $("#TeacherToken").index() - 1)
            $('#TeacherToken').val(randomString(16));
        else if (index == $("#StudentToken").index() - 1)
            $('#StudentToken').val(randomString(16));
    });
    $('#btnSave').on('click', function () {
        $('#submission').validate();
        //enable ClassID and EnrolledStudents
        dialogInputArr.eq(0).prop('disabled', false);
        $('#submission').submit();
    });

    function updateTextInput(val) {
        document.getElementById('textInput').value = val;
    }

    $(document).ready(function () {
        var table = $('#datatables').DataTable({
            responsive: true,
            "initComplete": function (settings, json) {
                $('.input-sm').eq(1).val($("#keyword").val().trim());
            },
            "aoColumnDefs": [
                {"bSearchable": false, "aTargets": [0]}
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
