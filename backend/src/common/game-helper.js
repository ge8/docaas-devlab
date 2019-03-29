const aws = require('aws-sdk');

class Helper {
    constructor(event) {
        this._event = event;
    }

    withCors(response) {
        var origin = this.event.headers.origin || this.event.headers.Origin;
        var requestHeaders = this.event.headers["access-control-request-headers"] || this.event.headers["Access-Control-Request-Headers"];
        response.headers = {
            'Access-Control-Max-Age': '900',
            'Access-Control-Allow-Headers': requestHeaders,
            'Access-Control-Allow-Origin': origin,
            'Access-Control-Allow-Credentials': 'true',
            'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS', 
            'Vary': 'Origin'
        };
        return response;
    }

    async getScores(deckName) {
        return this._callGameDataAccess("get", { deck:deckName });
    }
    async saveScores(deckName, scores) {
        return this._callGameDataAccess("save", { deck:deckName, scores:scores });
    }
    
    get event() {
      return this._event;
    }

    get plan() {
        return this.event.requestContext && this.event.requestContext.authorizer && this.event.requestContext.authorizer.plan ? this.event.requestContext.authorizer.plan : "gold";
    }

    getParam(name) {
        let val = this._event.queryStringParameters ? this._event.queryStringParameters[name] : null;
        if (!val && this._event.data && this._event.data[name]) {
            return this._event.data[name];
        } else return val;
    }

    async _callGameDataAccess(method, params) {
        let data = {
            plan: this.plan,
            method: method,
            params: params
        }
        // If credentals provided in context, then use them
        if (this.event.requestContext && this.event.requestContext.authorizer && this.event.requestContext.authorizer.accessKeyId) {
            data.credentials = {
                accessKeyId: this.event.requestContext.authorizer.accessKeyId, 
                secretAccessKey: this.event.requestContext.authorizer.secretAccessKey, 
                sessionToken: this.event.requestContext.authorizer.sessionToken, 
                identityId: this.event.requestContext.authorizer.identityId
            }
        }
        
        let lambda = new aws.Lambda();
        let invokeParams = {
                FunctionName: "DOCAAS_GameDataAccess",
                InvocationType: "RequestResponse",
                LogType: "Tail",
                Payload: JSON.stringify(data)
           };

        let result = await lambda.invoke(invokeParams).promise();
        console.log("DA Result:", result);
        return JSON.parse(result.Payload);
    }
  }
  
module.exports.Helper = Helper;