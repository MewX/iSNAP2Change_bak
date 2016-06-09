<?php
    session_start();
    require_once("../mysql-lib.php");
    require_once("../debug.php");
    	      
    $conn = db_connect();
    echo '###########################<br>';
    echo 'UNIT TEST<br>';
    echo '###########################<br>';
    echo 'getStuQuizScore(\$conn, $quizID, $studentID)<br>';
    for($i=-1;$i<10;$i++){
        for($j=-1;$j<10;$j++){
            echo "getStuQuizScore(\$conn, $i, $j) ".getStuQuizScore($conn, $i, $j)."<br>";   
        }
    }	
    
    echo '###########################<br>';
    echo 'UNIT TEST<br>';
    echo '###########################<br>';
    echo 'getQuizPoints(\$conn, $quizID)<br>';
    for($i=-1;$i<10;$i++){
        echo "getQuizPoints(\$conn, $i) ".getQuizPoints($conn, $i)."<br>";   
    }	
    
    
    
    echo '###########################<br>';
    echo 'UNIT TEST<br>';
    echo '###########################<br>';
    echo 'calculateStudentScore(\$conn, $studentID)<br>';
    for($i=-1;$i<10;$i++){
        echo "calculateStudentScore(\$conn, $i) ".calculateStudentScore($conn, $i)."<br>";   
    }
    
    echo '###########################<br>';
    echo 'UNIT TEST<br>';
    echo '###########################<br>';
    echo 'getStudentScore(\$conn, $studentID)<br>';
    for($i=-1;$i<10;$i++){
        echo "getStudentScore(\$conn, $i) ".getStudentScore($conn, $i)."<br>";   
    }

    echo '###########################<br>';
    echo 'UNIT TEST<br>';
    echo '###########################<br>';
    echo 'updateStudentScore($studentID)<br>';
    for($i=-1;$i<10;$i++){
        echo "updateStudentScore(\$conn, $i) ".updateStudentScore($conn, $i)."<br>";  
        echo getStudentScore($conn, $i),"<br>";
    }
    

    echo '###########################<br>';
    echo 'UNIT TEST<br>';
    echo '###########################<br>';
    echo 'updateStudentScore($studentID)<br>';
    for($i=-1;$i<10;$i++){
        echo "updateStudentScore(\$conn, $i) ".updateStudentScore($conn, $i)."<br>";  
        echo getStudentScore($conn, $i),"<br>";
    }

    
    /*
    echo '###########################<br>';
    echo 'UNIT TEST<br>';
    echo '###########################<br>';
    echo 'beginTransaction()<br>';
    echo 'getStudentScore(\$conn, 1) '.getStudentScore($conn, 1).'<br>';
    try{
        $studentID = 1;
        $conn->beginTransaction();              
        $make_err = false;
        
        $updateSql = "UPDATE Student 
                SET Score = ?
                WHERE StudentID = ?";			
        $updateSql = $conn->prepare($updateSql);         
        $updateSql->execute(array(100, $studentID)); 
        echo 'getStudentScore(\$conn, 1) '.getStudentScore($conn, 1).'<br>';
        
        if($make_err){
            $overviewName = 'mysql-lib';
            $schoolName = 'Sample School';                 
            $updateSql = "INSERT INTO School(SchoolName)
             VALUES (?);";			
            $updateSql = $conn->prepare($updateSql);                
            $updateSql->execute(array($schoolName));
        }    
        $updateSql = "UPDATE Student 
                SET Score = ?
                WHERE StudentID = ?";			
        $updateSql = $conn->prepare($updateSql);         
        $updateSql->execute(array(1000, $studentID));          
        echo 'getStudentScore(\$conn, 1) '.getStudentScore($conn, 1).'<br>';
        
        $conn->commit();                    
    } catch(PDOException $e) {
        debug_pdo_err($overviewName, $e);
        $conn->rollback();
    } 
    echo 'getStudentScore(\$conn, 1) '.getStudentScore($conn, 1).'<br>';
    */
    
    function generateRandomString($length = 10) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}
    
    echo '###########################<br>';
    echo 'UNIT TEST<br>';
    echo '###########################<br>';
    echo 'createClass(\$conn, \$schoolID, \$className)<br>';
    for($i=-1;$i<10;$i++){
        echo "createClass(\$conn, \$schoolID, \$className)".createClass($conn, 1, generateRandomString())."<br>";
    }
    
    
    db_close($conn); 
    
    
?>