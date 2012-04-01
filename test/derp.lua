print("Hello from Lua script!")
print("This is called from the global context.")

total_time = 0
frame_count = 0

function derp.load()
    print("-- Loading...")
end

function derp.draw()
    -- print("Inside the drawing function.")
end

function derp.update(dt)
    total_time = total_time + dt
    frame_count = frame_count + 1
    print "-- Update"

    if frame_count >= 10 then
        print "LUA says goodbye and ends the game after this frame!"
        print ("Total time:  " .. total_time .. " seconds")
        print ("Frame count: " .. frame_count)
        derp.app:quit()
    end
end
