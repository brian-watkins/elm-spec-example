module State exposing (..)
import Api exposing (AccessToken)


type ProgramState
  = Unauthenticated
  | Authenticated ProgramModel


type alias ProgramModel =
  { accessToken: AccessToken
  , things: List String
  }


defaultThings : List String
defaultThings =
  [ "Default Thing 1"
  , "Default Thing 2"
  ]


withThings : ProgramState -> List String -> ProgramState
withThings state things =
  case state of
    Unauthenticated ->
      state
    Authenticated details ->
      Authenticated { details | things = things }
