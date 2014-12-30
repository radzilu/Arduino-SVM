import java.io.File;
import controlP5.*;
import processing.serial.*;

Serial serial;
PrintWriter output;

Textfield modelFileName;
Textfield scalingFileName;
Textfield outputFileName;
Textlabel text;

ControlP5 controlP5;

Button start;
Button close;

// variables to save the information from the model and the scaling document
String kernelType;
String[] modelData;
String[] scalingData;
String[] range;
String[] scale = new String[3];
String model = "";
int nr_sens = 0;
int nr_class;
int[] nr_sv;

String[] split;
StringList highRange = new StringList();
StringList lowRange = new StringList();

// setup the window
void setup() {
  size(300, 300);
  smooth();
  background(0, 0, 0);

  controlP5 = new ControlP5(this);

  modelFileName = controlP5.addTextfield("Model Path", 10, 10, 200, 20);
  modelFileName.setText("");
  scalingFileName = controlP5.addTextfield("Scaling Path", 10, 50, 200, 20);
  scalingFileName.setText("");
  outputFileName = controlP5.addTextfield("Output Folder Path", 10, 150, 200, 20);
  outputFileName.setText("");

  text = controlP5.addTextlabel("Text", "Please insert Files", 10, 100);


  stroke(255);
  line(10, 240, 290, 240);

  start = controlP5.addButton("Start", 150, 160, 260, 60, 20);
  close = controlP5.addButton("Close", 150, 230, 260, 60, 20);
}
void draw() {
}
// controleEvent is triggered by start and close buttons
// if start is pressed a new Arduino Sketch is created from the model and the scaling range
// if close is pressed the window is closed
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(start)) {
    
    // creation of the output file writer and the input file readers
    output      = createWriter( outputFileName.getText()+"/sketch_svm/sketch_svm.ino" );
    modelData   = loadStrings(modelFileName.getText());
    scalingData = loadStrings(scalingFileName.getText());
    
    if (modelData == null || scalingData == null) {
      fill(0, 0, 0);
      stroke (0); 
      rect(10, 100, 200, 45);
      text.setText("Please insert correct paths");
      return;
    }

    // test if the correct kind of model is loaded
    split = split(modelData[0], " ");
    if (!split[0].equals("svm_type")) {
      fill(0, 0, 0);
      stroke (0); 
      rect(10, 100, 200, 45);
      text.setText("Please insert a model file path");
      return;
    } else if (!split[1].equals("c_svc")) {
      fill(0, 0, 0);
      stroke (0); 
      rect(10, 100, 200, 45);
      text.setText("Please insert a c_svc model");
      return;
    } else {
      split = split(modelData[1], " ");

      if (!(split[1].equals("polynomial")||split[1].equals("linear")||split[1].equals("rbf")||split[1].equals("sigmoid"))) {
        fill(0, 0, 0);
        stroke(0);
        rect(10, 100, 200, 45);
        text.setText("Please insert a model with one of the following kernels:\npolynomial, linear, rbf, sigmoid");
        return;
      }

        split = split(scalingData[0], " ");

        // test if the correct kind of scaling file is loaded
        if (!split[0].equals("x")) {
          fill(0, 0, 0);
          stroke(0);
          rect(10, 100, 200, 45);
          text.setText("Please insert a scaling file path");
          return;
        }


          // create the Arduino sketch from the model and scaling parameters
          boolean sv = false;
          output.println("#include <avr/pgmspace.h>");
          // for every line of the model file read the information and create the Arduino sketch
          for (int i = 0; i < modelData.length; i++) {

            split = split(modelData[i], " ");
            // if the section with SV's is already reached start to save the SV's and Yalphas
            if (sv) {

              int x = 0;
              int start = i;

              while (x < nr_sv.length) {
                String[] yalpha = new String[nr_sv.length - 1];
                String[] svs = new String[nr_sv[x]];

                for (int r = 0; r< yalpha.length; r++) {
                  yalpha[r] = "";
                }
                for (int r = 0; r< svs.length; r++) {
                  svs[r] = "";
                }
                for (int y = start; y < start + nr_sv[x]; y++) {
                  split = split(modelData[y], " ");                  
                  int nr = 1;

                  for (int j = 0; j < yalpha.length; j++) {
                    if (j == yalpha.length-1 && y == start + nr_sv[x]-1) {
                      yalpha[j] = yalpha[j] +split[j];
                    } else {
                      yalpha[j] = yalpha[j] +split[j] + ", ";
                    }
                  }
                  for (int j = yalpha.length; j < split.length-1; j++) {
                    String[] part = split(split[j], ":");
                    if (j == split.length-2 && y == start + nr_sv[x]-1) {
                      while (nr < int (part[0]) ) {
                        svs[y-start] = svs[y-start]  + "0";
                        nr++;
                      }
                      svs[y-start] = svs[y-start] + split(split[j], ":")[part.length -1];
                      nr++;
                    } else {
                      while (nr < int (part[0]) ) {
                        svs[y-start] = svs[y-start]  + "0" + ", ";
                        nr++;
                      }
                      svs[y-start] = svs[y-start] + split(split[j], ":")[part.length -1] + ", " ;
                      nr++;
                    }
                  }
                  if (nr > nr_sens) {
                    nr_sens = nr-1;
                  }
                }
                model = model + "\n const PROGMEM float yalpha"+str(x+1)+"["+str(nr_sv[x])+" * (NR_CLASS-1)] = {";
                for (int t = 0; t < yalpha.length; t++) {
                  model = model + yalpha[t];
                }
                model = model + "}; \n";
                model = model + "\n const PROGMEM float sv"+str(x+1)+"["+str(nr_sv[x])+" * VEC_DIM] = {";
                for (int p = 0; p < svs.length; p++) {

                  model = model + svs[p];
                }
                model = model + "}; \n";

                start = start + nr_sv[x] - 1;
                x++;
              } 
              output.println("#define VEC_DIM " + str(nr_sens));
              break;
              // as long as the SV section is not reached read out the other data
            } else {
              if (split.length > 2) {
                if (split[0].equals("rho")) {
                  model = model + "\n" + "const  PROGMEM float " + split[0]+"[]" + " = {";
                } else {
                  model = model + "\n" + "const int " + split[0]+"[]" + " = {";
                }
                if (split[0].equals("nr_sv")) {
                  for (int j = 1; j < split.length; j++) {
                    nr_sv[j-1] = int(split[j]);
                  }
                }
                for (int j = 1; j < split.length; j++) {
                  if (j == split.length -1) {
                    model = model + split[j] + "};";
                  } else {
                    model = model + split[j] + ", ";
                  }
                }
              } else if (!split[0].equals("SV")) {
                if (split[0].equals("nr_class")) {
                  nr_class = int(split[1]);
                  nr_sv = new int[nr_class];
                }
                if (split[0].equals("gamma")) {
                  model = model + "\n" + "#define GAMMA "  + split[1];
                }
                if (split[0].equals("rho")) {
                  model = model + "\n" + "const  PROGMEM float " + split[0]+"[]" + " = {" + split[1] + "};";
                }
                if (split[0].equals("nr_class")) {
                  model = model + "\n" + "#define NR_CLASS "  + split[1];
                }
                if (split[0].equals("total_sv")) {
                  model = model + "\n" + "#define TOTAL_SV " +  split[1];
                }
                if (split[0].equals("degree")) {
                  model = model + "\n" + "#define DEGREE " +  split[1];
                }
                if (split[0].equals("coef0")) {
                  model = model + "\n" + "#define COEF0 " +  split[1];
                }
                if (split[0].equals("svm_type")) {
                  model = model + "\n" + "#define SVM_TYPE " +  split[1] ;
                }
                if (split[0].equals("kernel_type")) {
                  kernelType = split[1];
                  model = model + "\n" + "#define KERNEL_TYPE " +  split[1] ;
                }
                if (split[0].equals("nr_sv")) {
                  for (int j = 1; j < split.length; j++) {
                    nr_sv[j-1] = int(split[j]);
                  }
                }
                if (split[0].equals("nr_sv")||split[0].equals("label")) {
                  model = model + "\n" + "const int " + split[0]+"[]" + " = {" + split[1] + "};";
                }
              } else {
                sv = true;
              }
            }
          }

          // output the information of the model into the Arduino sketch
          output.println(model); 
          // read in the scaling parameters
          for (int i = 0; i < scalingData.length; i++) {
            if (i == 1) {
              range = split(scalingData[i], " ");
              scale[0] = "const int scalePar[] = {"+range[0]+","+range[1]+"};";
              scale[1] = "const int low[] = {";
              scale[2] = "const int high[] = {";
            } else if (i > 1) {
              split =  split(scalingData[i], " ");

              if (i == scalingData.length -1) {
                scale[1]= scale[1]+ split[1] + "};";
                scale[2]= scale[2]+ split[2] + "};  ";
              } else {
                scale[1]= scale[1]+ split[1] + ",";
                scale[2]= scale[2]+ split[2] + ",";
              }
            }
          }
          // output the scaling parameters
          for (int i = 0; i<scale.length; i++) {
            output.println(scale[i]);
          }
          
          // output of all other needed data of the Arduino sketch
          output.println("int result[NR_CLASS]={0};");

          output.println("\n float const* const supportVectors[NR_CLASS] PROGMEM = {");
          for (int t = 1; t <= nr_class; t++) {
            output.print("sv"+str(t)+", ");
          }
          output.print("};");

          output.println("\n const float* const valuesForSupport[NR_CLASS] PROGMEM = {");
          for (int t = 1; t <= nr_class; t++) {
            output.print("yalpha"+str(t)+", ");
          }
          output.print("};");

          output.print("\n\nvoid scale(const int* sensor, float* scaledSensor){\n  for(int p=0; p<VEC_DIM;p++){\n    scaledSensor[p] = (float)scalePar[0] +((float)scalePar[1] -((float)scalePar[0]))*((float)sensor[p]-(float)low[p])/((float)high[p]-(float)low[p]);\n  }\n}");
          output.println("\n\ninline void svm_predict(int sensor[]){\n  int recognizedClass = 1;\n  float scaledSensor[VEC_DIM];\n  scale(sensor,scaledSensor);\n  int rhoCounter = 0;");
          output.println("\n\n  for(int i=0; i<NR_CLASS; i++){\n    for(int j=i+1; j<NR_CLASS; j++){\n      float accumulator = 0;");
          output.println("\n\n      float* sv_class1 = (float*) pgm_read_word(supportVectors + i);\n      float* sv_class2 = (float*) pgm_read_word(supportVectors + j);\n      float* coeffs1   = (float*) pgm_read_word(valuesForSupport + i) + nr_sv[i] * (j-1);\n     float* coeffs2   = (float*) pgm_read_word(valuesForSupport + j) + nr_sv[j] * i;"); 
          output.println("\n\n      accumulator += svm_evaluate(nr_sv[i], coeffs1, sv_class1, scaledSensor);\n      accumulator += svm_evaluate(nr_sv[j], coeffs2, sv_class2, scaledSensor);");
          output.println("\n\n      float rhoNr = pgm_read_float(rho + rhoCounter);\n      accumulator -= rhoNr;");
          output.println("\n\n      if (accumulator > 0) {\n        result[i]++;\n      } else {\n        result[j]++;\n      }\n      rhoCounter++;\n    }\n  }");
          output.println("\n\n  int temp = 0;\n  for(int t = 0; t < NR_CLASS; t++){\n    if(result[temp] <= result[t]){\n      recognizedClass = t;\n      temp = t;\n    }\n  }");
          output.println("\n\n  Serial.println(recognizedClass, DEC);\n  delay(500);\n  for(int q = 0; q < NR_CLASS; q++){\n    result[q]=0;\n  }\n}");
          output.flush();  
          output.close();  
          // selection of the used kernel class
          if (kernelType.equals("linear")) {
            output = createWriter( outputFileName.getText()+"/sketch_svm/linear_kernel.ino" );
            output.println("#ifndef VEC_DIM\n#error \n#endif\n\n#include <avr/pgmspace.h>\n\ninline float linear_kernel(float* u, float* v){\n  float result=0;\n  for (int j=0; j<VEC_DIM; j++){\n    result += pgm_read_float(u + j) * v[j];\n  }\n  return result;\n}");
            output.flush();  
            output.close();
          }

          output = createWriter( outputFileName.getText()+"/sketch_svm/measurement.ino" );
          output.println("#include <avr/pgmspace.h>\n\n // In this section you should implement the handling of your sensor data, which you would like to classify.\n // and an example would be:\nint sensors[5] = {0}; ");
          output.println("\n// int sensor1, sensor2, sensor3, sensor4, sensor5;");
          output.println("\n void setup(){\n  Serial.begin(115200);\n}");
          output.println("\nvoid loop(){");
          output.println("\n  //sensor1 = analogRead(0);\n  //sensor2 = analogRead(1);\n  //sensor3 = analogRead(2);\n  //sensor4 = analogRead(3);\n  //sensor5 = analogRead(4);\n  //delay(600);\n  // sensors= {sensor1, sensor2, sensor3, sensor4, sensor5};");
          output.println("\n  svm_predict(sensors);\n}");
          output.flush();  
          output.close();
          if (kernelType.equals("polynomial")) {
            output = createWriter( outputFileName.getText()+"/sketch_svm/polynomial_kernel.ino" );
            output.println("#ifndef VEC_DIM\n#error\n#endif\n\n#ifndef GAMMA\n#error\n#endif\n\n#ifndef COEF0\n#error\n#endif\n\n#ifndef DEGREE\n#error\n#endif\n\n#include <avr/pgmspace.h>\n");
            output.println("inline float polynomial_kernel(float* u, float* v){\n  float result=0;\n\n  for (int j=0; j<VEC_DIM; j++){\n    result += pgm_read_float(u + j) * v[j];\n  }\n\n  return pow((GAMMA * result + COEF0),DEGREE);\n}");
            output.flush();  
            output.close();
          }

          if (kernelType.equals("rbf")) {
            output = createWriter( outputFileName.getText()+"/sketch_svm/rbf_kernel.ino" );
            output.println("#ifndef VEC_DIM\n#error\n#endif\n\n#ifndef GAMMA\n#error\n#endif\n\n#include <avr/pgmspace.h>");
            output.println("\ninline float rbf_kernel(float* u, float* v){\n  float result=0;\n  for (int j=0; j<VEC_DIM; j++){\n    float temp = pgm_read_float(u + j) - v[j];\n    result += temp * temp;\n  }\n  return exp(-GAMMA * result);\n}");
            output.flush();  
            output.close();
          }

          if (kernelType.equals("sigmoid")) {
            output = createWriter( outputFileName.getText()+"/sketch_svm/sigmoid_kernel.ino" );
            output.println("#ifndef VEC_DIM\n#error\n#endif\n\n#ifndef GAMMA\n#error\n#endif\n\n#ifndef COEF0\n#error\n#endif\n\n#include <avr/pgmspace.h>\n\n");
            output.println("inline float sigmoid_kernel(float* u, float* v){\n  float result=0;\n  for (int j=0; j<VEC_DIM; j++){\n    result += pgm_read_float(u + j) - v[j];\n  }\n  return tanh(GAMMA * result + COEF0);\n}");
            output.flush();  
            output.close();
          }


          output = createWriter( outputFileName.getText()+"/sketch_svm/svm_evaluate.ino" );
          output.println("#ifndef VEC_DIM\n#error\n#endif\n\n#include <avr/pgmspace.h>\n\n");
          output.println("inline float svm_evaluate(int n_sv, float* coeffs, float* sv_class, float* sensors){\n  float result= 0;\n  float* sv_current = sv_class;\n  for (int i=0; i<n_sv; i++, sv_current += VEC_DIM){\n    float coeff = pgm_read_float(coeffs + i);\n");
          if (kernelType.equals("rbf")) {
            output.println("\n    result += coeff * rbf_kernel(sv_current, sensors);");
          } else if (kernelType.equals("sigmoid")) {
            output.println("\n    result += coeff * sigmoid_kernel(sv_current, sensors);");
          } else if (kernelType.equals("linear")) {
            output.println("\n    result += coeff * linear_kernel(sv_current, sensors);");
          } else if (kernelType.equals("polynomial")) {
            output.println("\n    result += coeff * polynomial_kernel(sv_current, sensors);");
          }
          output.println("\n  }");
          output.println("\n  return result;");
          output.println("\n}");
          output.flush();  
          output.close();

          exit();
        
      
    }
  } else if (theEvent.isFrom(close)) {
    exit();
  }
}  

