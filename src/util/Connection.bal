package com.uxscripts.backend.util;

import ballerina.data.sql;

map props = {"jdbcUrl":"jdbc:mysql://localhost:3308/uxscripts",
                "username":"root",
                "password":"1234"};

function getConnection () returns (sql:ClientConnector dbConnection){
    dbConnection = create sql:ClientConnector(props);
    return ;
}
