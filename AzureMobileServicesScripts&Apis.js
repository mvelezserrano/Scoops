//////////////////////////////////////////////
// API's
//////////////////////////////////////////////

// getheadlines
exports.get = function(request, response) {
    
    var querySQL = "SELECT id, title, authorName, imageurl FROM news WHERE status = 2";
    var mssql = request.service.mssql;
    
    mssql.query(querySQL, {
        success: function(result) {
            response.send(200,result);
        },
        error: function(error) {
            response.error(error);
        }
    });
};



// getheadlinesforauthor
exports.get = function(request, response) {
    var autor = request.query.authorId;
    var querySQL = "SELECT id, title, authorName, status, imageurl FROM news WHERE authorId = '"+ autor +"'";
    var mssql = request.service.mssql;
    
    mssql.query(querySQL, {
        success: function(result) {
            response.send(200,result);
        },
        error: function(error) {
            response.error(error);
        }
    });
};



// getsasurlforblob
var azure = require('azure');
var qs = require('querystring');
var appSettings = require('mobileservice-config').appSettings;

exports.get = function(request, response) {
    var accountName = appSettings.BLOB_ACCOUNT;
    //var accountName = request.service.config.appSettings.BLOB_ACCOUNT;
    var accountKey = appSettings.BLOB_ACCESS_KEY;
    //var accountKey = request.service.config.appSettings.BLOB_ACCESS_KEY;
    var host = accountName + '.blob.core.windows.net';
    var blobService = azure.createBlobService(accountName, accountKey, host);
    
    var sharedAccessPolicy = { 
        AccessPolicy: {
            Permissions: 'rw', //Read and Write permissions
            Expiry: minutesFromNow(5) 
        }
    };
    
    var sasUrl = blobService.generateSharedAccessSignature(request.query.containerName,
                    request.query.blobName, sharedAccessPolicy);

    var sasQueryString = { 'sasUrl' : sasUrl.baseUrl + sasUrl.path + '?' + qs.stringify(sasUrl.queryString),
                            'imageUrl' : sasUrl.baseUrl + sasUrl.path };                    

    request.respond(200, sasQueryString);
    console.log(sasQueryString);
};

function formatDate(date) { 
    var raw = date.toJSON(); 
    // Blob service does not like milliseconds on the end of the time so strip 
    return raw.substr(0, raw.lastIndexOf('.')) + 'Z'; 
} 

function minutesFromNow(minutes) {
    var date = new Date()
  date.setMinutes(date.getMinutes() + minutes);
  return date;
}



// getuserinfofromauthprovider
var appSettings = require('mobileservice-config').appSettings;

exports.get = function(request, response) {
    
    var idDB = appSettings.FACEBOOK_APP_ID;
    
    request.user.getIdentities({
        success: function (identities) {
            var http = require('request');
            console.log('Identities: ', identities);
            var url = 'https://graph.facebook.com/me?fields=id,name,birthday,hometown,email,picture,gender,friends&access_token=' +
                identities.facebook.accessToken;
    
            var reqParams = { uri: url, headers: { Accept: 'application/json' } };
            http.get(reqParams, function (err, resp, body) {
                var userData = JSON.parse(body);
                console.log('Logado -> ' + userData.name);
                response.send(200, userData);
            });
        }
    });
};



// valoranoticia
exports.get = function(request, response) {
    var paramResponse = response;
    var idScoop = request.query.idScoop
    var querySQL = "Select * from news where id ='" + idScoop +"'";
    var newValoracionesCount;
    var newValoracion;
    
    var mssql = request.service.mssql;
    
    mssql.query(querySQL, {
        success:function(result) {
            var sumValoraciones = parseFloat(result[0].valoracion) * parseFloat(result[0].valoracionesCount);
            sumValoraciones = parseFloat(sumValoraciones) + parseFloat(request.query.newRating);
            newValoracionesCount = parseFloat(result[0].valoracionesCount) + parseFloat(1);
            newValoracion = parseFloat(sumValoraciones / newValoracionesCount);
            updateScoop();
        },
        error:function(error) {
            response.error(error);
        }
    });
    
    function updateScoop () {
        console.log("Entramos a updateScoop");
        var updateSQL = "UPDATE news SET valoracion = " + newValoracion +", valoracionesCount = " 
            + newValoracionesCount + " WHERE id ='" + idScoop +"'";
        mssql.query(updateSQL, {
            success:function(result) {
                paramResponse.send(200, result);
            }//,
            //error:function(error) {
            //    paramResponse.error(error);
            //}
        });
    }
};



//////////////////////////////////////////////
// Scripts table
//////////////////////////////////////////////

// Insert
function insert(item, user, request) {
    item.valoracion = 0;
    item.valoracionesCount = 0;
    request.execute();
}



//////////////////////////////////////////////
// Scheduler jobs
//////////////////////////////////////////////

// publishScoops (Run every 1 hour)
function publishScoops() {
    var newsTable = tables.getTable("news");
    var sql = "UPDATE news SET status = 2 WHERE status = 1";
    mssql.query(sql, {
        success: function(results) {
            console.log('Noticias publicadas');
        }
    });
}


