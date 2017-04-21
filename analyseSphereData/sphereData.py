import pandas as pd
import matplotlib.pyplot as plt
import sys

fileName = sys.argv[1]
df = pd.read_csv(fileName)

magnitude = df['wearable-mag-xl1']
datetime = pd.to_datetime(df['datetime'])


plt.plot(datetime, magnitude)
plt.show()
