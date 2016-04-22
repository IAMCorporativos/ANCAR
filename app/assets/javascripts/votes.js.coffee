App.Votes =

  hoverize: (votes) ->
    $(votes).hover ->
      $("div.anonymous-votes", votes).show();
      $("div.organizations-votes", votes).show();
      $("div.not-logged", votes).show();
      $("div.logged", votes).hide();
    , ->
      $("div.anonymous-votes", votes).hide();
      $("div.organizations-votes", votes).hide();
      $("div.not-logged", votes).hide();
      $("div.logged", votes).show();

  initialize: ->
    App.Votes.hoverize votes for votes in $("div.votes")
    App.Votes.hoverize votes for votes in $("div.supports")
    false
