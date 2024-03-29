<?php
session_start();
require_once("../mysql-lib.php");
require_once("../debug.php");
require_once("researcher-lib.php");

if (isset($_GET['quizID']) && isset($_GET['studentID'])) {
    $quizID = $_GET['quizID'];
    $studentID = $_GET['studentID'];
}

try {
    $conn = db_connect();
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_POST['update'])) {
            $update = $_POST['update'];
            if ($update == 0) {
                $saqID = $_POST['saqID'];
                $feedback = $_POST['feedback'];
                $grading = $_POST['grading'];
                updateSAQSubmissionGrading($conn, $quizID, $saqID, $studentID, $feedback, $grading);
                $parentPage = 'Location: ' . strtolower(getQuizType($conn, $quizID)) . '-grading.php';
                header($parentPage);
            }
        }
    }
} catch (Exception $e) {
    debug_err($e);
}

try {
    $saqSubmissionResult = getSAQSubmission($conn, $quizID, $studentID);
    $materialRes = getLearningMaterial($conn, $quizID);
    $phpSelf = $pageName . '.php?quizID=' . $quizID . '&studentID=' . $studentID;
} catch (Exception $e) {
    debug_err($e);
}

db_close($conn);
?>
<!DOCTYPE html>
<html lang="en">

<!-- Header Library -->
<?php require_once('header-lib.php'); ?>

<body>

<div id="wrapper">
    <!-- Navigation Layout-->
    <?php require_once('navigation.php'); ?>

    <div id="page-wrapper">
        <div class="row">
            <div class="col-lg-12">
                <h1 class="page-header">Grader</h1>
            </div>
            <!-- /.col-lg-12 -->
        </div>
        <!-- /.row -->
        <div class="row">
            <div class="col-lg-12">

                <!-- Questions -->
                <div class="panel panel-default">
                    <div class="panel-heading">
                        Student Submission
                    </div>
                    <!-- /.panel-heading -->
                    <div class="panel-body">

                        <?php require_once('learning-material.php'); ?>

                        <!-- Grader -->
                        <form id="submission" method="post" action="<?php echo $phpSelf ?>">
                            <input type=hidden name="update" id="update" value="0" required>
                            <?php for ($i = 0; $i < count($saqSubmissionResult); $i++) {
                                $saqID = $saqSubmissionResult[$i]->SAQID;
                                ?>
                                <div class="well row">
                                    <input type=hidden name="saqID[]" value="<?php echo $saqID ?>" required>
                                    <label for=question[]">Question:</label>
                                    <textarea class="form-control" id="question[]" rows="2"
                                              disabled><?php echo $saqSubmissionResult[$i]->Question ?></textarea>
                                    <br>
                                    <label for=studentAnswer[]">Student Answer:</label>
                                    <textarea class="form-control" id="studentAnswer[]" rows="8"
                                              disabled><?php echo $saqSubmissionResult[$i]->Answer ?></textarea>
                                    <br>
                                    <label for="feedback[]">Feedback</label>
                                    <input type="text" class="form-control dialogInput"
                                           id="feedback<?php echo $saqID ?>"
                                           name="feedback[]"
                                           placeholder="Input Feedback"
                                           value="<?php echo $saqSubmissionResult[$i]->Feedback ?>" required>
                                    <br>
                                    <label for="grading[]">Grading</label>
                                    <input type="text" class="dialoginput pull-right" id="textInput<?php echo $saqID ?>"
                                           value="<?php echo $saqSubmissionResult[$i]->Grading > 0 ? $saqSubmissionResult[$i]->Grading : $saqSubmissionResult[$i]->Points; ?>"
                                           disabled>
                                    <input type="range" class="dialoginput" min="0"
                                           max="<?php echo $saqSubmissionResult[$i]->Points ?>"
                                           value="<?php if (strlen($saqSubmissionResult[$i]->Grading) > 0) echo $saqSubmissionResult[$i]->Grading; else echo $saqSubmissionResult[$i]->Points ?>"
                                           id="grading" name="grading[]"
                                           onchange="updateTextInput(<?php echo $saqID ?>, this.value);">
                                </div>
                            <?php } ?>
                        </form>
                    </div>
                    <!-- /.panel-body -->
                    <div class="panel-footer text-center">
                        <button type="button" id="btnSave" class="btn btn-default btn-info">Save</button>
                    </div>
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

<!-- SB Admin Library -->
<?php require_once('sb-admin-lib.php'); ?>
<!-- Page-Level Scripts -->
<script>
    function updateTextInput(saqID, val) {
        document.getElementById('textInput' + saqID).value = val;
    }

    $(document).ready(function () {
        $('#btnSave').on('click', function () {
            $('#submission').validate();
            $('#submission').submit();
        });
    });
</script>
</body>

</html>
