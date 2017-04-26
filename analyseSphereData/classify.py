import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from sklearn.cluster import KMeans


def getFeatures(fileName):
    df = pd.read_csv(fileName, index_col='datetime')

    # arm angle calculation using accelerometer data
    df['angle'] = 180 / np.pi * np.arctan(df['wearable-xl1-z'] / np.sqrt(np.square(df['wearable-xl1-x']) + np.square(df['wearable-xl1-z'])))

    # get only interesting columns
    df = df[['angle', 'wearable-mag-xl1']]

    # remove NaN values
    df = df.dropna()

    # convert index to DatetimeIndex
    df.index = pd.DatetimeIndex(df.index)


    # resample data within interval given in resampleInterval ('1S' = 1 second intervals)
    resampleInterval = '1S'
    min = df.resample(resampleInterval).min()
    max = df.resample(resampleInterval).max()
    mean = df.resample(resampleInterval).mean()
    std = df.resample(resampleInterval).std()
    sum = df.resample(resampleInterval).sum()

    # stack features intu np matrix
    # format: [angMin, magMin, angMax, magMax, angMean, magMean, angStd, magStd, angSum, magSum]
    features = np.hstack((min.as_matrix(), max.as_matrix()))
    features = np.hstack((features, mean.as_matrix()))
    features = np.hstack((features, std.as_matrix()))
    features = np.hstack((features, sum.as_matrix()))

    return [features, std]

[features, std] = getFeatures('data_01.csv')

label = KMeans(n_clusters=2, random_state=10).fit_predict(features)

plt.scatter(std.index, std.angle, c=label)
plt.xlim(std.index[0], std.index[len(std.index)-1])
plt.show()