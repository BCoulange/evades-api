require('coffee-script')

express = require("express")
app = express()
url = require 'url'
http = require "http"
request = require('request');

Logger = require('devnull')
logger = new Logger()

ical2json = require("ical2json");


agenda_url_ical = process.env.AGENDA_ICAL_URL || "https://www.google.com/calendar/ical/lhl27borhs7assr7e9aff9u3jk%40group.calendar.google.com/public/basic.ics"

# json_version_with_extern_api = "http://ical2json.pb.io/#{agenda_address_ical}"

convert_ical_to_spectacle = (json_hash) ->
  content = json_hash.content
  icalStr = json_hash.DTSTART
  # icalStr = '20110914T184000Z'             
  strYear = icalStr.substr(0,4)
  strMonth = parseInt(icalStr.substr(4,2),10)-1
  strDay = icalStr.substr(6,2)
  strHour = icalStr.substr(9,2);
  strMin = icalStr.substr(11,2);
  strSec = icalStr.substr(13,2);
  {
    id: json_hash.UID
    title: json_hash.SUMMARY
    date: new Date(strYear,strMonth, strDay, strHour, strMin, strSec)
    place: json_hash.LOCATION
    message: json_hash.DESCRIPTION
  }

app.use (req, res, next) ->
    # Website you wish to allow to connect
    res.setHeader('Access-Control-Allow-Origin', '*');
    # Request methods you wish to allow
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    # # Request headers you wish to allow
    # res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');
    # # Set to true if you need the website to include cookies in the requests sent
    # # to the API (e.g. in case you use sessions)
    # res.setHeader('Access-Control-Allow-Credentials', true);
    # # Pass to next layer of middleware
    next();

app.get "/", (req, res) ->
  res.send "Welcome this awesome api"
  
app.get '/api/v1/spectacles', (req,res) ->
  request.get agenda_url_ical, (error, response, body) ->
    if (!error && response.statusCode == 200)
      ical = body  
      json = ical2json.convert(ical)
      result = {spectacles: []}
      result.spectacles = (convert_ical_to_spectacle(spectacle) for spectacle in json.VCALENDAR[0].VEVENT)
      res.send result

port = process.env.PORT || "3000"
app.listen port 
logger.info "App listening on port #{port}"


