Arduino-SVM
===========
Arduino-SVM is a Processing sketch which builds Arduino sketches from LibSVM (http://www.csie.ntu.edu.tw/~cjlin/libsvm/ ) models and scaling data. They can be used in conjunction with LibSVM to classify newly measured data with a Arduino micro-controller-board.

- Arduino-SVM (for now) only works with C-SVC support vector machines using one of the following kernels: linear, polynomial, radial basis function or sigmoid.
- The Arduino sketches which are build by Arduino-SVM consist of functions to scale and classify, for example, sensor data shortly after they are measured by the micro controller's sensors. To use it follow the steps below:
- Measure training data.
(the data should be in the following format 0 1:234 2:345 3:423 ... (class label 1:sensor1 2:sensor2 3:sensor3...) see therefore the example of measured data in Model_Examples/data.txt)
- Scale your training data with LibSVM's svm-scale tool. Normally -1 and 1 works well as lower and upper bounds (see Model_Examples/data.scale.txt)
- Train the SVM with your training data and create a LibSVM model (svm-train) use  as SVM-type C-SVC and as kernel: linear, polynomial, radial basis function or sigmoid (Model_Examples/data.scale.model.<kernel-type>).
- Use Arduino-SVM to create an Arduino sketch with which a prediction is made to which of the trained classes newly measured data could belong. To do this you have to start the processing sketch Arduino-SVM and insert in the textfields the paths to the LibSVM model, and the LibSVM scaling data file (in the example the file is Model_Examples/range). You have to insert the path in which the newly created folder for the Arduino sketch should be saved. To use the build Arduino sketch you have to insert in measurement.ino your code to measure your sensor data, the data must be in the same order as the training data and all done preprocessing steps which have been used before the training data was scaled and used for training with help of LibSVM must be done with newly measured data as well. Your data should be saved then in an int array and forwarded to the prediction function.
- In rbf_example you can see a complete (and commented) Arduino sketch in which the data of 9 sensors is classified to 5 classes using an rbf kernel.
- The build Arduino sketch forwards the recognized class (label: 0,1...n) to the Serial Monitor with a baud rate of 115200.

Status
=========
This is beta code. We've done ad-hoc testing primarily with a RBF kernel. Please let us know if you find mistakes and feel free to change the code to your needs. To use the program you have to have LibSVM, Arduino and Processing installed on your computer, also you nead the ControleP5 libery for processing. We tested with LibSVM 3.12, Arduino 1.0.6 and Processing 2.2.1.
