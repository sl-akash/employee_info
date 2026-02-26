<?php
	if ($_SERVER['REQUEST_METHOD'] == "POST") {
	    
		$request_type = $_POST['request_type'];
		$data = $_POST['data'];
		
		if ($request_type == "insert_user") {
		    insert_user($data);
		} else if ($request_type == "update_user") {
		    update_user($data);
		}
	} else if ($_SERVER['REQUEST_METHOD'] == "GET") {
	    
	    $request_type = $_GET['request_type'];
	    $data = $_GET['data'];
	    
	    if ($request_type == "get_all_user") {
	        get_all_user();
	    } else if ($request_type == "auth_user") {
	        get_current_user2($data);
	    }
	    
	   // echo "hello";
	} else if ($_SERVER['REQUEST_METHOD'] == "DELETE") {
	    $request_type = $_GET['request_type'];
	    $data = $_GET['data'];
	    
	    if ($request_type == "delete_user") {
	        delete_user($data);
	    }
	    
	   // echo($request_type);
	}

    function get_current_user2($data) {
        // echo "good";
        $insert_data = [$data['email']];
        // echo json_encode($insert_data);
        $insert_query = "SELECT * FROM tbl_users WHERE email = ?";
        
        $get_data = get_data_row_from_database($insert_query, $insert_data);
        
        $return_data = [
                "status" => "error",
                "message" => "invalid-user"
            ];
        
        if ($get_data) {
            if (password_verify($data['password'], $get_data['password'])) {
                $return_data['status'] = "success";
                $return_data['message'] = json_encode($get_data);
            } else {
                $return_data['message'] = "invalid-credential";
            }
        }
        
        echo json_encode($return_data);
        
    }

    function insert_user($data) {
        $data = json_encode($data);
        $data = json_decode($data);
        
        $insert_data = [$data->staffName, $data->employeeId, $data->countryCode, $data->phoneNumber, $data->email, password_hash($data->password, PASSWORD_DEFAULT), $data->imageUrl, $data->isActive, $data->isAdmin, $data->joiningDate, $data->lastDate, $data->insertedDate, $data->updatedDate, $data->insertedBy, $data->updatedBy];
        $insert_query = "INSERT INTO tbl_users (staffName, employeeId, countryCode, phoneNumber, email, password, imageUrl, isActive, isAdmin, joiningDate, lastDate, insertedDate, updatedDate, insertedBy, updatedBy) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $data_response = [
            "status" => "failure",
            "message" => "User Insert Error"
            ];
        
        $email_data = [$data->email, $data->employeeId];
        
        $email_query = "SELECT email, employeeId FROM tbl_users WHERE (email = ? OR employeeId = ?)";
        
        $email_data = get_data_row_from_database($email_query, $email_data);
        
        if ($email_data) {
            if ($email_data['email'] == $data->email) {
                $data_response["message"] = "Email Id Exists";
            } else {
                $data_response["message"] = "Employee Id Exists";
            }
        } else if (insert($insert_query, $insert_data)) {
            $data_response["status"] = "success";
            $data_response["message"] = "User Created Successfully";
        }
        
        echo(json_encode($data_response));
        
    }
    
    function update_user($data) {
        $data = json_encode($data);
        $data = json_decode($data);
        
        $data_response = [
            "status" => "failure",
            "message" => "User Update Error"
        ];
        
        // echo("pass is {$data->password}");
        
        $update_data = [$data->staffName, $data->countryCode, $data->phoneNumber, $data->imageUrl, $data->isActive, $data->isAdmin, $data->lastDate, $data->updatedDate, $data->updatedBy, $data->id];
            
        $update_query = "UPDATE tbl_users SET staffName=?, countryCode=?, phoneNumber=?, imageUrl=?, isActive=?, isAdmin=?, lastDate=?, updatedDate=?, updatedBy=? WHERE id=?";
        
        
        if ($data->password != "") {
            $data_response["message"] = "{$data->password} is the password";
            
            $update_data = [$data->staffName, $data->countryCode, $data->phoneNumber, $data->imageUrl, password_hash($data->password, PASSWORD_DEFAULT), $data->isActive, $data->isAdmin, $data->lastDate, $data->updatedDate, $data->updatedBy, $data->id];
            
            $update_query = "UPDATE tbl_users SET staffName=?, countryCode=?, phoneNumber=?, imageUrl=?, password=?, isActive=?, isAdmin=?, lastDate=?, updatedDate=?, updatedBy=? WHERE id=?";
        }
        
        if (insert($update_query, $update_data)) {
            $data_response["status"] = "success";
            $data_response["message"] = "User Updated Successfully";
        }
        
        echo(json_encode($data_response));
        
    }
    
    function delete_user($data) {
        $delete_data = [$data["id"]];
        $delete_query = "DELETE FROM tbl_users WHERE id = ?";
        
        $data_response = [
            "status" => "failure",
            "message" => "user-update-error"
        ];
        
        if (insert($delete_query, $delete_data)) {
            $data_response["status"] = "success";
            $data_response["message"] = "user-deleted";
        }
        
        echo(json_encode($data_response));
        
    }
    
    function get_all_user() {
        $user_query = "SELECT * FROM tbl_users";
        
        $user_data = get_data_list_from_database($user_query);
        
        echo(json_encode($user_data));
        
    }

	function register_user($data) {
		$data = json_decode($data);
		$email = $data->email;
		$password = $data->password;
		$user_query = "SELECT * FROM tbl_user WHERE email='$email'";
		$user_data = get_data_row_from_database($user_query);

		if ($user_data) {
			echo "existing";
		} else {
		    $data = [
		            "email" => $email,
		            "password" => $password
		        ];
		    
			$insert_query = "INSERT INTO tbl_user (`email`, `password`) VALUES (:email, :password)";
			if (insert($insert_query, $data)) {
				$user_query = "SELECT * FROM tbl_user WHERE email='$email'";
				$user_data = get_data_row_from_database($user_query);
				echo $user_data->id;
			} else {
				echo "failure";
			}
		}
	}
	
	function link_to_server()
    {
        $hostname = 'localhost';
        $username = 'u331977297_employee';
        $password = 'p>q9+*Q0';
        $dbh = new PDO("mysql:host=$hostname;dbname=$username", $username, $password);
        return $dbh;
    }
    
    function get_data_list_from_database($sql_query)
    {
        try {
            $dbh = link_to_server();
            $result = $dbh->prepare($sql_query);
            $result->execute();
            $result_data = $result->fetchAll();
            $dbh = null;
            return $result_data;
        } catch (PDOException $e) {
            return null;
        }
    }
    
    function get_data_row_from_database($sql_query, $data = null)
    {
        try {
            $dbh = link_to_server();
            $result = $dbh->prepare($sql_query);
            $result->execute($data);
            $result_data = $result->fetchAll();
            $dbh = null;
            return $result_data[0];
        } catch (PDOException $e) {
            echo $e;
            return null;
        }
    }
    
    function insert($sql_query, $data)
    {
        try {
            $dbh = link_to_server();
            $result = $dbh->prepare($sql_query);
            $result->execute($data);
            $dbh = null;
            return true;
        } catch (PDOException $e) {
            echo $e;
            return false;
        }
    }
    
    function delete_data($sql_query)
    {
    	try {
    		$dbh = link_to_server();
    		$result = $dbh->prepare($sql_query);
    		$result->execute();
    		return true;
    	} catch (PDOException $e) {
    	    return false;
    	}
    }
	
?>
