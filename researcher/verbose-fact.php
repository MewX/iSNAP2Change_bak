<?php
session_start();
require_once("../mysql-lib.php");
require_once("../debug.php");
require_once("researcher-lib.php");
$columnName = array('FactID', 'TopicName', 'Title', 'Content', 'Edit');

try {
    $conn = db_connect();
    $topicResult = getTopics($conn);
    $verboseFactResult = getVerboseFacts($conn);
    $phpSelf = $pageName;
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
                <h1 class="page-header">Verbose Fact Overview</h1>
            </div>
            <!-- /.col-lg-12 -->
        </div>
        <!-- /.row -->
        <div class="row">
            <div class="col-lg-12">
                <!-- Options -->
                <div class="panel panel-default">
                    <div class="panel-heading">
                        Verbose Information Table
                    </div>
                    <!-- /.panel-heading -->
                    <div class="panel-body">
                        <div class="dataTable_wrapper">
                            <table class="table table-striped table-bordered table-hover" id="datatables">
                                <?php require_once('table-head.php'); ?>
                                <tbody>
                                <?php

                                define("SUB_CONTENT_INDEX", 3);
                                define("EDIT_INDEX", 4);
                                define("OMIT_LEN", 40);

                                for ($i = 0;
                                     $i < count($verboseFactResult);
                                     $i++) { ?>
                                    <tr class="<?php if ($i % 2 == 0) {
                                        echo "odd";
                                    } else {
                                        echo "even";
                                    } ?>">
                                        <?php
                                        for ($j = 0;
                                             $j < count($columnName);
                                             $j++) { ?>
                                            <td <?php if ($j == 0) echo 'style="display:none"'; ?>>
                                                <?php if ($j != EDIT_INDEX && $j != SUB_CONTENT_INDEX)
                                                echo $verboseFactResult[$i]->$columnName[$j];
                                                else if ($j == SUB_CONTENT_INDEX) {
                                                    $content = $verboseFactResult[$i]->$columnName[$j];
                                                    $collapseTextID = "collapse-" . $verboseFactResult[$i]->VerboseFactID;
                                                    if (strlen($content) == 0) { ?>
                                                        <div class="alert alert-danger">
                                                            <p><strong>Reminder</strong> : You have not added any
                                                                verbose fact for this topic!
                                                        </div>
                                                    <?php } else if (strlen($content) < OMIT_LEN) {
                                                        echo $content;
                                                    } else { ?>
                                                        <p>
                                                            <?php echo mb_strcut($content, 0, OMIT_LEN) . "..."; ?></p>
                                                        <a href="#<?php echo $collapseTextID; ?>"
                                                           class="btn btn-info" data-toggle="collapse">Show Full
                                                            Paragraph</a>
                                                        <div id="<?php echo $collapseTextID; ?>" class="collapse">
                                                            <?php echo $content; ?>
                                                            <span
                                                                class="glyphicon glyphicon-volume-up pull-right tts"
                                                                aria-hidden="true"></span>
                                                        </div>

                                                    <?php }
                                                } else if ($j == EDIT_INDEX){ ?>
                                                <a href="verbose-fact-editor.php?topicID=<?php echo $verboseFactResult[$i]->TopicID ?>"><span
                                                        class="pull-right" aria-hidden="true">&nbsp;</span><span
                                                        class="glyphicon glyphicon-edit pull-right" data-toggle="modal"
                                                        data-target="#dialog" aria-hidden="true"></span>
                                                    <?php } ?>
                                            </td>
                                        <?php } ?>
                                    </tr>
                                <?php } ?>
                                </tbody>
                            </table>
                        </div>
                        <!-- /.table-responsive -->
                        <div class="well row">
                            <h4>VerboseFact Overview Notification</h4>
                            <div class="alert alert-info">
                                <p>View verbose facts for each topic by filtering or searching. You can
                                    edit the facts in one topic by clicking the edit button.</p>
                            </div>
                            <div class="alert alert-info">
                                <p>For long paragraphs, it will only show part of content to make this table clean, if
                                    you want to view full paragraph, you can click the <b>"Show Full
                                    Paragraph"</b> buttons in the cells.</p>
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

<!-- SB Admin Library -->
<?php require_once('sb-admin-lib.php'); ?>
<!-- Page-Level Scripts -->
<script>
    $(document).ready(function () {
        var table = $('#datatables').DataTable({
            responsive: true,
            //rows group for Question and edit box
            rowsGroup: [1, 4],
            "pageLength": 100,
            "aoColumnDefs": [
                {"bSearchable": false, "aTargets": [0]}
            ]
        });
    });
</script>
<script src="researcher-tts.js"></script>
</body>

</html>
