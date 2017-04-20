import pandas as pd
import matplotlib.pyplot as plt


fileName = 'data_00.csv.gz'
df = pd.read_csv(fileName)

magnitude = df['wearable-mag-xl1']
datetime = pd.to_datetime(df['datetime'])


plt.plot(datetime, magnitude)
plt.show()