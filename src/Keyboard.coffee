class Keyboard

    self = this;
    @keyDownEvents = new Array()
    @keyUpEvents = new Array()

    do ->
        # Trigger a key DOWN event if it exists in the keyDownEvents array
        onKeyDown = (event) ->
            for downEvent in self.keyDownEvents
                if downEvent.key is event.keyCode and downEvent.triggered != true
                    downEvent.triggered = true
                    downEvent.callback()
            undefined

        # Trigger a key UP event if it exists in the keyUpEvents array
        onKeyUp = (event) ->
            #alert(event.keyCode)
            for downEvent in self.keyDownEvents
                if downEvent.key is event.keyCode
                    downEvent.triggered = false
            for upEvent in self.keyUpEvents
                if upEvent.key is event.keyCode
                    upEvent.callback()
            undefined

        # Add key listeners
        document.addEventListener("keydown", onKeyDown, false)
        document.addEventListener("keyup", onKeyUp, false)
        undefined

    @bind: (action, boundEvent) ->
        # Bind a new key DOWN event if it does not already exist
        if action is "press"
            for downEvent in @keyDownEvents
                if downEvent.key is boundEvent.key and downEvent.callback is boundEvent.callback
                    console.warn("The same key down event cannot be bound twice -> \nkey: " + boundEvent.key + "\ncallback: " + boundEvent.callback)
                    doNotBind = true;
                    break
            @keyDownEvents.push(boundEvent) if not doNotBind

        # Bind a new key UP event if it does not already exist
        else if action is "release"
            for upEvent in @keyUpEvents
                if upEvent.key is boundEvent.key and upEvent.callback is boundEvent.callback
                    console.warn("The same key up event cannot be bound twice -> \nkey: " + boundEvent.key + "\ncallback: " + boundEvent.callback)
                    doNotBind = true;
                    break
            @keyUpEvents.push(boundEvent) if not doNotBind
        undefined

    @unbind: (action, boundEvent) ->
        # Find and remove a key DOWN event from the keyDownEvents array
        if action is "press"
            for downEvent, i in @keyDownEvents
                if boundEvent.key is downEvent.key and boundEvent.callback is downEvent.callback
                    @keyDownEvents.splice(i, 1)
                    break

        # Find and remove a key UP event from the keyDownEvents array
        else if action is "release"
            for upEvent, i in @keyUpEvents
                if boundEvent.key is upEvent.key and boundEvent.callback is upEvent.callback
                    @keyUpEvents.splice(i, 1)
                    break
        undefined

window.Keyboard = Keyboard
