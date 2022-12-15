package org.example;

import java.lang.*;

public class LutTableGenerator
{
    static final int nBit = 16;
    static final int nSamples = 95;
    static int maxNumber = ((int) Math.pow(2, (nBit- 1))) - 1;
    static int minNumber = 0 - maxNumber;
    static int currentValue = 0;
    static int lastValue = -1; //To know if the function was going down or up
    static StringBuffer values = new StringBuffer();

    public static void main( String[] args )
    {

        //String to display
        values.append(currentValue);
        values.append(", ");
        //TriangularWaveGenerator();
        SinWaveGenerator();
        System.out.println("Max Value: " + maxNumber + "; Min Value: " + minNumber);
        System.out.println(values);
    }

    private static void TriangularWaveGenerator()
    {
        //We add a random value between maxNumber/8 and maxNumber/4!
        for(int i = 1; i < nSamples; i++)
        {
            int random = GetRandomNumber(maxNumber/8, maxNumber/4);

            if(currentValue == maxNumber) //Peak point
            {
                lastValue = currentValue;
                currentValue = currentValue - random;
            }
            else if(currentValue == minNumber) //Min point
            {
                lastValue = currentValue;
                currentValue = currentValue + random;
            }
            else if(currentValue > lastValue) //Increasing
            {
                lastValue = currentValue;
                if (currentValue + random < maxNumber)
                    currentValue = currentValue + random;
                if (currentValue + random >= maxNumber)
                    currentValue = maxNumber;
            }
            else if(currentValue < lastValue) //Decreasing
            {
                lastValue = currentValue;
                if (currentValue - random > minNumber)
                    currentValue = currentValue - random;
                if (currentValue - random <= minNumber)
                    currentValue = minNumber;
            }

            //save the value
            values.append(currentValue);
            values.append(", ");

        }
    }

    private static void SinWaveGenerator()
    {

        double degreeStep = 720/(nSamples - 1); //4pi divided by the number of samples

        for(int i = 1; i < nSamples; i++)
        {
            currentValue = (int) (maxNumber * (Math.sin(Math.toRadians(i * degreeStep))));
            values.append(currentValue);
            values.append(", ");
        }
    }
    private static int GetRandomNumber(int min, int max) {
        return (int) ((Math.random() * (max - min)) + min);
    }
}
