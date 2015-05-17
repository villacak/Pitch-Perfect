# Pitch-Perfect
My very first project from Udacity iOS Developer Nanodegree.

I have added a few of exra things to the project as some comments within the code.
The extra things I have added are:
disable button when the app is doing something;
enable the button once the task has finished.
If recording the background is set to red.

The most important thing that I have added is to use this .setCategory(AVAudioSessionCategoryRecord, error: nil) instead the one
the course has shown that was using AVAudioSessionCategoryPlayAndRecord as it worked really well on my mac though I barely could
hear, even with the volume at max, on my device. Then set the category back to AVAudioSessionCategoryPlay.

Thinks that I couldn't improve is the AVAudioPlayerMode that take too long to finish the task, should have a better way,
to stop and finish it instead just rely on completionHandler.



