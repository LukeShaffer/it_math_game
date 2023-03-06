#include <iostream>
#include <cstdlib>
#include <time.h>

int main(int argc, char** argv){
	srand(time(NULL));


	int operation=rand()%4; //random number from 0 to 3
	
	//set the 2 operands
	int a=rand()%100;
	int b=rand()%100;
	
	//c is the right answer, d is the wrong answer
	int c=0,d=0;
	//a always needs to be biggest so division is simpler on me
	if (a<b){
		c=a; a=b;b=c;
	}
	
	switch(operation){
		case(0):
			c=a+b;
			break;
		
		case(1):
			c=a-b;
			break;

		case(2):
			c=a*b;
			break;

		case(3):
			// division is a special case, just generate a result and have them
			// get the original value of "a" to ensure ints
			c=a;
			a*=b;
			break;			
	}

	//calculate the wrong answer as a percentage of the correct answer
	int answer_noise= (c*.10);
	int neg_chance=rand()%2;
	if(neg_chance)
		d=c-1-rand()%answer_noise;
	else
		d=c+1+rand()%answer_noise;

//	std::cout<<"operation:"<<operation<<std::endl;
//	std::cout<<"A("<<a<<") "<<" B("<<b<<") C("<<c<<")\n";
	

	std::cout<<a<<" "<<operation<<" "<<b<<" "<<c<<" "<<d<<"\n";
}
