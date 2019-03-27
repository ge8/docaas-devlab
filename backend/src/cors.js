'use strict';
exports.handle_request = async (event, context, callback) => {
    callback(null, {
        statusCode:'200',
        body: "",
        headers: {
            'Access-Control-Max-Age': '900',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Origin': '*', // Insecure
            'Access-Control-Allow-Credentials': 'true',
            'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS', 
            'Vary': 'Origin'
        }
    });
};