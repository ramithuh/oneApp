package com.uxscripts.backend;

import ballerina.net.http;
import ballerina.lang.messages;
import org.wso2.ballerina.connectors.gmail;
import ballerina.lang.system;
import ballerina.lang.strings;
import ballerina.lang.jsons;
import ballerina.lang.time;
import ballerina.lang.errors;
import com.uxscripts.backend.util;
import ballerina.data.sql;
import ballerina.lang.datatables;

@http:configuration {basePath:"/gmail"}
service<http> HelloService {



    @http:GET {}
    @http:Path {value:"/read"}
    resource sayHello (message m) {
        message response = {};
        string userId = "dizzyballerinalang@gmail.com";
        string accessToken = "ya29.GluQBB7duMIVfaOBxXdIL6YAn4n-lu6QJqtIyXd1xoW9PgQZ7dlMZtaShNjFW3FX3sEnGeJUfRnAABBSWFbS4YGDMS8tUV233b9fh1sLQjYGPg28dNy4n59CYFwB";
        string refreshToken = "1/vH6HOElw9P7OIoqWbraWaQqSyHZMW0khlewk9viOGBE";
        string clientId = "504699110285-2ni92qehhhi0unc64kim8nttvbfhg8vd.apps.googleusercontent.com";
        string clientSecret = "AmR8wUPiUsBSVf74JswSC2B6";

        gmail:ClientConnector gmailConnector = create gmail:ClientConnector(userId, accessToken, refreshToken, clientId, clientSecret);

        message gmailResponse;
        json gmailJSONResponse;
        gmailResponse = gmail:ClientConnector.listMails(gmailConnector, "null", "null", "null", "null", "null");
        gmailJSONResponse = messages:getJsonPayload(gmailResponse);

        int i = 0;
        int l = lengthof gmailJSONResponse.messages;
        while (i < l) {


            message gmailResponse1;
            json gmailJSONResponse1;
            string eid = strings:valueOf(gmailJSONResponse.messages[i].id);//emailid
            gmailResponse1 = gmail:ClientConnector.readMail(gmailConnector, strings:valueOf(gmailJSONResponse.messages[i].id), "null", "null");
            gmailJSONResponse1 = messages:getJsonPayload(gmailResponse1);
            string fullbody = jsons:toString(gmailJSONResponse1.snippet);//body-full
            string subject = jsons:toString(gmailJSONResponse1.payload.headers[20].value);//subject
            string[] a = strings:split(jsons:toString(gmailJSONResponse1.payload.headers[17].value), "<");
            string[] b = strings:split(a[1], ">");
            string from = b[0];//from
            i = i + 1;

            try {
                string[] body = strings:split(fullbody, ",");
                string dateTime_ = strings:replace(body[0], " ", "");
                time:Time timeParsed = time:parse(dateTime_ + ":00.444-0500",
                                                  "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                int milliSecond = time:milliSecond(timeParsed);
                system:println(time:toString(timeParsed));//time
                string descrip = body[1];

                sql:ClientConnector dbConnection = util:getConnection();

                sql:Parameter[] params = [];
                params = [{sqlType:"varchar", value:eid}];
                datatable dt = sql:ClientConnector.select(dbConnection,
                                                          "SELECT TRUE FROM `note` WHERE `email_id`=?",
                                                          params);
                if (!datatables:hasNext(dt)) {
                    params = [{sqlType:"varchar", value:from}];
                    datatable dtn = sql:ClientConnector.select(dbConnection,
                                                              "SELECT `user_id` FROM `user` WHERE `email`=?",
                                                              params);
                    if (datatables:hasNext(dtn)) {

                        any dataStruct = datatables:next(dtn);
                        var rs, _ = (json )dataStruct;
                        string[] asss_1 = strings:split(strings:valueOf(dataStruct),":");
                        string asa = strings:replace(asss_1[1],"}","");
                        params = [{sqlType:"varchar", value:eid}
                                  , {sqlType:"timestamp", value:timeParsed}
                                  , {sqlType:"varchar", value:subject}
                                  , {sqlType:"varchar", value:descrip}
                                  , {sqlType:"varchar", value:asa}];

                        system:println(rs);
                        int ret = sql:ClientConnector.update(dbConnection,
                                                             "INSERT INTO `note`(`email_id`,`date_time`,`title`,`description`,`user_user_id`) VALUES (?,?,?,?,?)",
                                                             params);
                    }else{
                        system:println("Not ok");
                    }

                }
                sql:ClientConnector.close(dbConnection);
            } catch (errors:Error e) {
                system:println(e);
            }
        }
        messages:setStringPayload(response, "Hello World !!!");
        reply response;
    }
}
