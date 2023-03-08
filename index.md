# **Lab Report 5**

## **Summary and finishing Lab 6**

-   For this lab report, I want to finish up my grading script from lab 6, as well as explain in detail how exactly the script works.
-   First, here is my existing grading script:

```
CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'
TOTAL_AMOUNT=2

rm -rf student-submission
git clone $1 student-submission
echo 'Finished cloning'

# Check to see there is a file called ListExamples.java
if [[ -e ./student-submission/ListExamples.java && -f ./student-submission/ListExamples.java ]]
then
    echo 'ListExamples.java found! Continuing with tests...'
else
    echo 'ListExamples.java not found!'
    echo ""
    echo "0/$TOTAL_AMOUNT is the final score."
    echo ""
    exit
fi

# Copy our test code into the student's code
echo "Copying test code into student directory..."
cp TestListExamples.java ./student-submission/TestListExamples.java
cp -r ./lib ./student-submission/lib

# Compile all of the java files
echo "Compiling all java files..."
cd student-submission
javac -cp $CPATH *.java 2> javac-results.txt

# Detect if any errors happened
if [[ $? -ne 0 ]]
then
    echo "Error in compiling java files! Error messages below: "
    cat javac-results.txt
    echo ""
    echo "0/$TOTAL_AMOUNT is the final score."
    echo ""
    exit
else
    echo "Successfully compiled java files! Continuing with tests..."
fi

# Now running the tests on user code
echo 'Running tests on student submission...'
java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > test-results.txt

# Get second line in test-results.txt. The amount of E's will tell us the amount of failures vs. successes.
# Command below was found here: https://stackoverflow.com/questions/19327556/get-specific-line-from-text-file-using-just-shell-script
sed '2!d' test-results.txt > parser-results.txt
# Command below was found here: https://unix.stackexchange.com/questions/387656/how-to-count-the-times-a-specific-character-appears-in-a-file
grep -o 'E' parser-results.txt | wc -l > failure-amount.txt
FAILURE_AMOUNT=`cat failure-amount.txt`
let "correct = $TOTAL_AMOUNT - $FAILURE_AMOUNT"
if [[ $correct -ne $TOTAL_AMOUNT ]]
then
    echo "Printing out JUnit output since there were errors!"
    cat test-results.txt
fi
echo ""
echo "$correct/$TOTAL_AMOUNT is the final score."
echo ""
```

-   There are a couple things that I want to do with this script:
    1. Right now, the total amount of tests must be explicitly stated in the bash script. This is a bit inconvenient, since if I ever want to add anymore tests, I have to manually edit this number.
    2. The final grading right now is a fraction, and somewhat hard to understand. It would be nice to give the person a final grade, from F to A, as doing so would make grading easier.
-   Throughout this lab report, I'll go through the process of these changes, then explain the final grade script at the end.

### **1: Getting the Number of Tests**

-   I really don't like that I have to input the amount of tests manually. So, I want to be able to automatically get the number of tests.

#### **Method 1**

-   My first thought improvement was to make the number of tests an argument for the `grade.sh` script.
-   The way I did this was by changing `TOTAL_AMOUNT=2` to `TOTAL_AMOUNT=$2`.
-   This does make the script more flexible, as whenever we add another test, we do not have to directly change `grade.sh`, but rather just change the argument that we are passing in.
-   Here is an example output:

```
(base) gregoryweber@Gregorys-MacBook-Pro cse15l-lab-report-5 % bash grade.sh https://github.com/ucsd-cse15l-f22/list-methods-corrected 2
Cloning into 'student-submission'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 3 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
Finished cloning
ListExamples.java found! Continuing with tests...
Copying test code into student directory...
Compiling all java files...
Successfully compiled java files! Continuing with tests...
Running tests on student submission...

2/2 is the final score.
```

-   Even if we do not have to directly change the code to accomodate for new tests, this method is still a bit tedious, since it can be easy to forget to input the extra argument.
-   We also don't want to think about how many tests we have, but rather just make as many tests as we want, and for a final grade to be given.

#### **Method 2**

-   In order to automatically collect how many tests there are, we can count the number of lines that contain the string `@test`.
-   We will be using `grep` as well as `wc` to accomplish this.
-   First, we will grab all of the lines containing `@Test` using grep. The command I put in my bash script is:

```
grep "@Test" TestListExamples.java  > grep-results.txt
```

-   Next, we want to count the number of lines in `grep-results.txt`. This number will be the number of tests in the file. I then put the results of this command into the variable `TOTAL_AMOUNT`. The command I used is:

```
TOTAL_AMOUNT=`wc -l grep-results.txt`
```
