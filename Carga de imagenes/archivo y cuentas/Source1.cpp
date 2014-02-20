#include <iostream>
#include <fstream>
#include <set>
using namespace std;


int main(){
	ifstream fIn;
	ofstream fOut;
	//thing raro;
	//cosa rara;
	int numero;
	set<int> gluglu;
	fIn.open("archivo.txt");
	while (!fIn.eof())
	{
		fIn >> numero;
		gluglu.insert(numero);
	}
	cout << gluglu.size();
	char c=cin.get();
}