<?php
session_start();
require_once("../mysql-lib.php");
require_once("../debug.php");
require_once("researcher-validation.php");
$pageName = "learning-material-editor";

try {
    $conn = db_connect();
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_POST['richContentTextArea'])) {
            $conn = db_connect();
            $content = $_POST['richContentTextArea'];
            $quizID = $_POST['quizID'];
            updateLearningMaterial($conn, $quizID, $content);
        }
    }
} catch (Exception $e) {
    debug_err($pageName, $e);
}

try {
    if (isset($_GET['quizID'])) {
        $quizID = $_GET['quizID'];
        $materialRes = getLearningMaterial($conn, $quizID);
        $phpSelf = $pageName . '.php?quizID=' . $quizID;
    }
} catch (Exception $e) {
    debug_err($pageName, $e);
}

db_close($conn);
?>

<!DOCTYPE html>
<html>
<head>
    <!-- Bootstrap Core CSS -->
    <link href="../bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="//cdn.tinymce.com/4/tinymce.min.js"></script>
    <script>
        tinymce.init({
            selector: 'textarea',
            height: 500,
            theme: 'modern',
            plugins: [
                'advlist autolink lists link image charmap preview hr anchor pagebreak',
                'searchreplace wordcount visualblocks visualchars code fullscreen',
                'insertdatetime media nonbreaking save table contextmenu directionality',
                'emoticons template paste textcolor colorpicker textpattern imagetools'
            ],
            toolbar1: 'insertfile undo redo | styleselect | bold italic forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | emoticons link image media | preview',
            imagetools_toolbar: "rotateleft rotateright | flipv fliph | editimage imageoptions",
            image_advtab: true,
            browser_spellcheck: true,
            templates: [
                //infograph list
                {title: 'Infograph Demo', url: '../infograph/demo.html'}
            ],
            content_css: [
                '//fast.fonts.net/cssapi/e6dc9b99-64fe-4292-ad98-6974f93cd2a2.css',
                '//www.tinymce.com/css/codepen.min.css'
            ]
        });
    </script>
</head>
<body>
<form method="post" action="<?php echo $phpSelf ?>">
    <label for="QuizID" style="display:none">QuizID</label>
    <input type="text" class="form-control" id="QuizID" name="quizID" style="display:none"
           value="<?php echo $quizID; ?>" required>
    <textarea name="richContentTextArea">
        <?php echo $materialRes->Content; ?>
    </textarea>
    <input type="submit" name='submitbutton' value="Save" class='submit'/> <span
        class="glyphicon glyphicon-info-sign"></span><b> Ctrl + S</b><br>
</form>
</body>
</html>