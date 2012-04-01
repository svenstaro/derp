print("Hello from Lua script!")
print("This is called from the global context.")

total_time = 0

function derp.load()
    print("Loading stuff...")
end

function derp.draw()
    print("Inside the drawing function.")
end

function derp.update(dt)
    total_time = total_time + dt
    print("Inside the update function. Update time was " .. dt .. " seconds.")
    print("Total time: " .. total_time)

    if total_time > 2 then
        print "LUA says goodbye and ends the game after this frame!"
        derp.app:quit()
    end
end
