# Encoding-Transmiting-decoding-vedio
Project task: Simulating video transmission using MATLAB by encoding the video using different Convolutional codes then adding an error with probability p which simulate the channel  finally decoding the video
This code appears to be a MATLAB script that reads a video file, separates its color components into binary streams, encodes and decodes them using convolutional codes with different trellis structures, introduces errors, and finally decodes the received data to produce the reconstructed video frames. The script also calculates the probability of error for different error ranges, and plots the results.Here's an overview of the script's main steps:
1. Read the input video file and extract its color components.
2. Define different trellis structures for convolutional encoding.
3. For each frame of the input video, encode each color component using a specific trellis structure, introduce errors, and decode the received data.
4. Reconstruct the video frames using the decoded color components.
5. Calculate the probability of error for different error ranges and plot the results.
6. Write the reconstructed video frames to an output file.

The script contains several functions that perform specific tasks, such as encoding, decoding, and introducing errors. These functions are called within the main script to process the video frames.

Overall, the script demonstrates how error-correcting codes can be used to improve the reliability of data transmission over noisy channels, such as in video compression and transmission applications.
