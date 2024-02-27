module Api exposing (..)
import Http
import Json.Decode as Json


type AccessToken =
  AccessToken String


type alias ApiRequestDetails msg =
  { accessToken: AccessToken
  , url: String
  , expect: Http.Expect msg
  }


fetchAccessToken : String -> (Result Http.Error AccessToken -> msg) -> Cmd msg
fetchAccessToken baseUrl tagger =
  Http.get
    { url = baseUrl ++ "/accessToken"
    , expect = Http.expectJson tagger <| Json.map AccessToken Json.string
    }


authenticatedRequest : ApiRequestDetails msg -> Cmd msg
authenticatedRequest details =
  Http.request
    { method = "GET"
    , headers = [ authorizationHeader details.accessToken ]
    , url = details.url
    , body = Http.emptyBody
    , expect = details.expect
    , timeout = Nothing
    , tracker = Nothing
    }


authorizationHeader : AccessToken -> Http.Header
authorizationHeader (AccessToken token) =
  Http.header "Authorization" token