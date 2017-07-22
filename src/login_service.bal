package com.uxscripts.backend;

import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.data.sql;
import com.uxscripts.backend.util;
import ballerina.lang.datatables;
import ballerina.lang.strings;

@http:configuration {basePath:"/user"}
service<http> LoginService {

    @http:GET {}
    @http:Path {value:"/login"}
    resource loginResource (message m,
                       @http:QueryParam {value:"email"} string p_email,
                       @http:QueryParam {value:"pass"} string p_pass) {
        message response = {};

        p_email = strings:trim(p_email);
        p_pass = strings:trim(p_pass);

        string msg;
        if (p_email != "" && p_pass != "") {
            int ret = loginUser(p_email,p_pass);
            if(ret==1){
                msg = "Success";
            }else if(ret==2){
                msg = "Email Ok";
            }else{
                msg = "Invalid Data"+ret;
            }
        }else{
            msg = "Fields Cannot be empty!";
        }
        messages:setStringPayload(response, msg);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/register"}
    resource registerResource (message m,
                            @http:QueryParam {value:"email"} string p_email,
                            @http:QueryParam {value:"pass"} string p_pass) {
        message response = {};

        p_email = strings:trim(p_email);
        p_pass = strings:trim(p_pass);

        string msg;
        if (p_email != "" && p_pass != "") {
            int ret = registerUser(p_email,p_pass);
            if(ret==1){
                msg = "Success";
            }else if(ret==2){
                msg = "already_exist";
            }else{
                msg = "Invalid Data"+ret;
            }
        }else{
            msg = "Fields Cannot be empty!";
        }
        messages:setStringPayload(response, msg);
        reply response;
    }
}



function loginUser (string email, string pass) returns (int returnVal) {
    //return val > 1-success 2-emailOk/passWrong 3-invalid
    if (isValidEmail(email)) {
        sql:ClientConnector dbConnection = util:getConnection();
        sql:Parameter[] params = [];
        params = [{sqlType:"varchar", value:email}, {sqlType:"varchar", value:pass}];
        datatable dt = sql:ClientConnector.select(dbConnection,
                                                  "SELECT `user_id` FROM `user` WHERE `email`=? AND `password`=?",
                                                  params);

        if (datatables:hasNext(dt)) {
            returnVal = 1;
        } else {
            params = [{sqlType:"varchar", value:email}];
            dt = sql:ClientConnector.select(dbConnection,
                                            "SELECT true FROM `user` WHERE `email`=?",
                                            params);
            if (datatables:hasNext(dt)) {
                returnVal = 2;
            }else{
                returnVal = 3;
            }
        }
        sql:ClientConnector.close(dbConnection);
    }else{
        returnVal = 3;
    }
    return;
}

function registerUser (string email, string pass) returns (int returnVal) {
    //return val > 1-success 2-already_exist 3-invalid
    if (isValidEmail(email)) {
        sql:ClientConnector dbConnection = util:getConnection();
        sql:Parameter[] params = [];
        params = [{sqlType:"varchar", value:email}];
        datatable dt = sql:ClientConnector.select(dbConnection,
                                                  "SELECT `user_id` FROM `user` WHERE `email`=?",
                                                  params);

        if (datatables:hasNext(dt)) {
            returnVal = 2;
        } else {
            params = [{sqlType:"varchar", value:email}, {sqlType:"varchar", value:pass}];
            int ret = sql:ClientConnector.update(dbConnection,
                                                 "INSERT INTO `uxscripts`.`user`(`email`,`password`) VALUES (?,?)",
                                                 params);
            returnVal = 1;
        }
        sql:ClientConnector.close(dbConnection);
    } else {
        returnVal = 3;
    }
    return;
}

function isValidEmail (string email) returns (boolean returnVal) {
    returnVal = true;
    return;
}
