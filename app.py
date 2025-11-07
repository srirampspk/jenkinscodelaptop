from flask import Flask, render_template, request
import pickle
import pandas as pd

app = Flask(__name__)

# Load the trained pipeline model
with open('model.pkl', 'rb') as file:
    model = pickle.load(file)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        # Get form data
        data = {
            'Company': [request.form['Company']],
            'TypeName': [request.form['TypeName']],
            'Ram': [int(request.form['Ram'])],
            'Weight': [float(request.form['Weight'])],
            'Touchscreen': [int(request.form['Touchscreen'])],
            'Ips': [int(request.form['Ips'])],
            'ppi': [float(request.form['ppi'])],
            'Cpu brand': [request.form['CpuBrand']],
            'HDD': [int(request.form['HDD'])],
            'SSD': [int(request.form['SSD'])],
            'Gpu brand': [request.form['GpuBrand']],
            'os': [request.form['OS']]
        }
        # Convert to DataFrame
        input_df = pd.DataFrame(data)
        # Predict
        predicted_price = model.predict(input_df)[0]
        return render_template('index.html', prediction=round(predicted_price, 2))
    return render_template('index.html', prediction=None)

if __name__ == '__main__':
    app.run(debug=True)
