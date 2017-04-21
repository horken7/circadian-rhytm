import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import scipy.io
from datetime import datetime, timedelta

df = pd.read_csv(fileName)

magnitude = df['wearable-mag-xl1']
timestamp = pd.to_datetime(df['datetime'])

timestamp = timestamp[~np.isnan(magnitude)] # remove NaN corresponding to magnitude
magnitude = magnitude[~np.isnan(magnitude)] # remove NaN

acc_X = df['wearable-xl1-x']
acc_Y = df['wearable-xl1-y']
acc_Z = df['wearable-xl1-z']

acc_X = acc_X[~np.isnan(acc_X)]
acc_Y = acc_Y[~np.isnan(acc_Y)]
acc_Z = acc_Z[~np.isnan(acc_Z)]

angle = np.arctan( acc_Z / np.sqrt( np.square(acc_X) + np.square(acc_Y) ) ) * 180/np.pi # estimated arm angle

def makeChunk(timestamp):
    timestamp = timestamp.tolist()
    chunkedTime = []
    chunk = []
    previous = timestamp[0]
    for index, value in enumerate(timestamp):
        if(value - previous >= timedelta(minutes=5)):
            chunkedTime.append(chunk)
            chunk = []
            previous = value
        else:
            chunk.append([value, index])

def getDifference(chunk, angle):
    angleChunk = []
    for index, value in enumerate(chunk[]):
        angleChunk.append(angle[index])
        print(index)

def plotData(timestamp, magnitude, angle):
    plt.plot(timestamp, magnitude)
    plt.show()

    plt.plot(timestamp, angle)
    plt.show()

def datetime2matlabdn(dt):
    mdn = dt + timedelta(days=366)
    frac_seconds = (dt - datetime(dt.year, dt.month, dt.day, 0, 0, 0)).seconds / (24.0 * 60.0 * 60.0)
    frac_microseconds = dt.microsecond / (24.0 * 60.0 * 60.0 * 1000000.0)
    return mdn.toordinal() + frac_seconds + frac_microseconds

def convertMatlab(timestamp, acc_X, acc_Y, acc_Z):
    # convert to matlab datenum
    t = []
    timestamp.toList() # TODO: this might cause unresolved crash
    for x in timestamp:
        t.append(datetime2matlabdn(x))

    # save as .mat

    scipy.io.savemat('t.mat', {'struct':t})
    a = [acc_X,acc_Y,acc_Z]
    scipy.io.savemat('a.mat', {'struct':a})

makeChunk(timestamp)
