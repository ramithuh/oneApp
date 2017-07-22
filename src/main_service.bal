package com.uxscripts.backend;

import ballerina.net.http;
import ballerina.lang.messages;

@http:configuration {basePath:"/"}
service<http> MainService {

    @http:GET {}
    @http:Path {value:"/"}
    resource mainResource (message m) {
        message response = {};
        messages:setStringPayload(response, "Hello World !!!");
        reply response;
    }
}
