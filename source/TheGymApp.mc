using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Sensor;
using Toybox.Communications;
using Toybox.WatchUi as Ui;


const CLIENT_ID = "myClientID";
const OAUTH_CODE = "myOAuthCode";
const OAUTH_ERROR = "myOAuthError";


class TheGymApp extends Application.AppBase {

var view= null;
var hr= null;
var location= null;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	sensorInitialize();
  		initializePositionListener();
  // register a callback to capture results from OAuth requests
		Communications.registerForOAuthMessages(method(:onOAuthMessage));
  
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
    	view = new TheGymView();
    	//getOAuthToken();
    	
        return [ view, new TheGymDelegate() ];
    }
    
    function initializePositionListener() {
    Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );
}

function onPosition( info ) {
	if(view != null && info.position != null) {
		location = info.position.toDegrees();
		view.updateLocation(location[0], location[1]);
		makeRequest();
	}	
    //System.println( "Position " + info.position.toGeoString( Position.GEO_DM ) );
}

function sensorInitialize() {
	//System.println("Initialize...");
    Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
    Sensor.enableSensorEvents(method(:onSensor));
    //System.println("Initialized.");
}

function onSensor(sensorInfo) {
	hr= sensorInfo.heartRate;
	if(view != null && hr!= null) {
	 	view.updateHR(hr);
	 	makeRequest();
	 }
    //System.println("Heart Rate: " + sensorInfo.heartRate);
}

// wrap the OAuth request in a function
function getOAuthToken() {
   var status = "Look at OAuth screen\n";
   //Ui.requestUpdate();

   // set the makeOAuthRequest parameters
   var params = {
       "scope" => Communications.encodeURL("https://thegym-263112.appspot.com/app/home"),
       "redirect_uri" => "https://thegym-263112.appspot.com/auth/google/callback",
       "response_type" => "code",
       "client_id" => "$.CLIENT_ID"
   };
   
   // makeOAuthRequest triggers login prompt on mobile device
   Communications.makeOAuthRequest(
       "https://thegym-263112.appspot.com/app/home",
       params,
       "https://thegym-263112.appspot.com/app/home",
       Communications.OAUTH_RESULT_TYPE_URL,
       {"responseCode" => "OAUTH_CODE", "responseError" => "OAUTH_ERROR"}
   );
   System.println("getOAuthToken");
}

// implement the OAuth callback method
function onOAuthMessage(message) {
	System.println("onAuthMessage");
	System.println(message);
	
	
    if (message.data != null) {
        var code = message.data[OAUTH_CODE];
        var error = message.data[OAUTH_ERROR];
        System.print(message.data+" "+code+" "+error);
    } else {
        // return an error
    }
}


	function onReceive(responseCode, data) {
       if (responseCode == 200) {
     //      System.println("Request Successful");                   // print success
       }
       else {
      //     System.println("Response: " + responseCode);            // print response code
       }
   }

   function makeRequest() {
       var url = "https://thegym-263112.appspot.com/data";                         // set the url
	//System.print("make Request: "+url);
	var hs="---", lons="---", lats="---";
	
	if(hr!= null) {
		hs= hr+"";
	}
			
	if(location!= null) {
		lons= location[0]+"";
		lats= location[1]+"";
	}
       var params = {                                              // set the parameters
              "hr" => hs,
              "lon" => lons,
              "lat" => lats
       };

       var options = {                                             // set the options
           :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
           :headers => {                                           // set headers
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                                                                   // set response type
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_URL_ENCODED
       };

       var responseCallback = method(:onReceive);                  // set responseCallback to
                                                                   // onReceive() method
       // Make the Communications.makeWebRequest() call
       Communications.makeWebRequest(url, params, options, method(:onReceive));
  }

}
