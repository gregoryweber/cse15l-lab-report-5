# WINDOWS CPATH
CPATH='.;lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar'

# MAC CPATH
# CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

grep "@Test" TestListExamples.java | wc -l > failure-amount.txt
TOTAL_AMOUNT=`cat failure-amount.txt`

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
echo "-----------------------------------------------------------------"

echo "Tests passed: $correct/$TOTAL_AMOUNT"

percentage=$(awk "BEGIN {printf \"%.0f\", $correct/$TOTAL_AMOUNT*100}")
echo "Percentage of tests passed: $percentage%"

# if (( $(echo "$percentage >= 90" | bc -l) )); then
if [[ $percentage -ge 90 ]]; then
  echo "Grade: A"
elif [[ $percentage -ge 80 ]]; then
  echo "Grade: B"
elif [[ $percentage -ge 70 ]]; then
  echo "Grade: C"
elif [[ $percentage -ge 60 ]]; then
  echo "Grade: D"
else
  echo "Grade: F"
fi

echo "-----------------------------------------------------------------"
echo ""
