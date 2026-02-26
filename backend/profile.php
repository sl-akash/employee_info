<?php
    $targetDir = "profile/";
    $fileName = basename($_FILES["image"]["name"]);
    $targetFile = $targetDir . $fileName;

    $imageFileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
    
    $targetFile = $targetDir . uniqid("IMG_", true) . "." . $imageFileType;

    $response = [];
    $response['status'] = "error";
    $response['message'] = "Invalid request method";

    // Allowed formats
    $allowedTypes = ["jpg", "jpeg", "png", "gif"];
    
    if (!is_dir($targetDir)) {
        // Create folder
        mkdir($targetDir, 0777, true);
            
    }
    

    if (in_array($imageFileType, $allowedTypes)) {

        if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
            $response['status'] = "success";
            $response['message'] = $targetFile;
        } else {
            $response['message'] = "Error uploading file.";
        }

    } else {
        $response['message'] = "Only JPG, JPEG, PNG & GIF files are allowed.";
    }
    
    echo json_encode($response);
?>
