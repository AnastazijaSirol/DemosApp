from flask import Flask, render_template
from flask_mysqldb import MySQL

from flask import request, redirect, url_for

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost' # adresa
app.config['MYSQL_USER'] = 'root' # korisničko ime
app.config['MYSQL_PASSWORD'] = 'root' # lozinka
app.config['MYSQL_DB'] = 'trgovina' # naziv baze
app.config['MYSQL_CURSORCLASS'] = 'DictCursor' # rezultati rječnici

# MYSQL objekt
mysql = MySQL(app)

# Rute

@app.route('/')
def index():
    return render_template('index.html')

# Prikaz svih kupaca
@app.route('/kupci')
def kupci():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM kupac")
    podaci = cur.fetchall()
    cur.close()

    return render_template('kupci.html', kupci=podaci)

# Prikaz svih zaposlenika
@app.route('/zaposlenici')
def zaposlenici():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM zaposlenik")
    podaci = cur.fetchall()
    cur.close()

    return render_template('zaposlenici.html', zaposlenici=podaci)

# Prikaz svih računa
@app.route('/racuni')
def racuni():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT 
            r.id,
            r.broj,
            r.datum_izdavanja,
            k.ime AS kupac_ime,
            k.prezime AS kupac_prezime,
            z.ime AS zap_ime,
            z.prezime AS zap_prezime
        FROM racun r
        JOIN kupac k ON r.id_kupac = k.id
        JOIN zaposlenik z ON r.id_zaposlenik = z.id
        ORDER BY r.datum_izdavanja
    """)
    racuni = cur.fetchall()
    cur.close()

    return render_template('racuni.html', racuni=racuni)

# Dodavanje novog zaposlenika
@app.route('/novi_zaposlenik', methods=['GET', 'POST'])
def novi_zaposlenik():
    # POST metoda
    if request.method == 'POST':
        # Dohvaćanje podataka
        id = request.form['id']
        ime = request.form['ime']
        prezime = request.form['prezime']
        oib = request.form['oib']
        datum = request.form['datum']

        cur = mysql.connection.cursor()
        cur.execute("""
            INSERT INTO zaposlenik 
            (id, ime, prezime, oib, datum_zaposlenja)
            VALUES (%s, %s, %s, %s, %s)
        """, (id, ime, prezime, oib, datum))

        # Spremanje promjena u bazu
        mysql.connection.commit()
        cur.close()

        return redirect(url_for('index'))

    # GET metoda
    return render_template('novi_zaposlenik.html')

# Brisanje računa određenog kupca
@app.route('/obrisi_racune_kupca/<int:id_kupac>')
def obrisi_racune_kupca(id_kupac):
    cur = mysql.connection.cursor()

    cur.execute("""
        DELETE FROM racun
        WHERE id_kupac = %s
    """, (id_kupac,))

    mysql.connection.commit()
    cur.close()

    return redirect(url_for('kupci'))

# Prikaz detalja računa
@app.route('/stavke/<int:id_racun>')
def stavke(id_racun):
    cur = mysql.connection.cursor()

    # Poziv procedure
    cur.callproc('stavke_racuna', [id_racun])
    stavke = cur.fetchall()

    # NAPOMENA: funkcija bi se koristila kao SELECT iz tablice

    cur.close()
    return render_template('stavke.html', stavke=stavke, racun_id=id_racun)

if __name__ == '__main__':
    app.run(debug=True)
