/* Predikat likes yang menggambarkan fakta berupa relasi
dari user kepada movie yang disukainya */
:- dynamic likes/2.

/* Predikat closeness yang menyatakan tingkat kedekatan dua user
yang disimpan pada variabel Closeness dan dihitung berdasarkan
banyaknya movie yang disukai oleh kedua user tersebut */
closeness(User1, User2, Closeness) :-
    likes(User1, Liked1),
    likes(User2, Liked2),
    findall(Movie,
            (member(Movie, Liked1), member(Movie, Liked2)),
            Intersection),
    length(Intersection, Closeness).

/* Predikat find_max_closeness mencari user lain
dengan closeness terbesar terhadap seorang user
yang disimpan pada variabel UserRecommended */
find_max_closeness(_, _, UserRecommended,
                   UserRecommended, []) :- !.

find_max_closeness(User, MaxCloseness, CurrUR,
                   UserRecommended, [H | T]) :-
    User = H, !,
    find_max_closeness(User, MaxCloseness, CurrUR,
                       UserRecommended, T).

find_max_closeness(User, MaxCloseness, _,
                   UserRecommended, [H | T]) :-
    closeness(User, H, CurrCloseness),
    CurrCloseness > MaxCloseness,
    likes(User, LUser),
    likes(H, LOther),
    findall(Movie,
            (member(Movie, LOther), \+member(Movie, LUser)),
            Recommendation),
    Recommendation \== [], !,
    find_max_closeness(User, CurrCloseness, H,
                   UserRecommended, T).
    
find_max_closeness(User, MaxCloseness, CurrUR,
                   UserRecommended, [_ | T]) :-
    find_max_closeness(User, MaxCloseness, CurrUR,
                   UserRecommended, T).

/* Predikat find_recommendation mencari rekomendasi film
untuk seorang user berdasarkan film yang disukai oleh user lain
yang memiliki closeness terbesar dengannya dan hasilnya
disimpan pada variabel Recommendation */
find_recommendation(User, OtherUser, Recommendation) :-
    likes(User, LUser),
    likes(OtherUser, LOther),
    findall(Movie,
            (member(Movie, LOther), \+member(Movie, LUser)),
            Recommendation).

/* Predikat recommend akan mengembalikan film-film
rekomendasi (Recommendation) untuk seorang user (User) */
recommend(User, Recommendation) :-
    setof(UserName, Liked^likes(UserName, Liked), ListOfUser),
    find_max_closeness(User, -1, _,
                       UserRecommended, ListOfUser),
    find_recommendation(User, UserRecommended, Recommendation).

/* Predikat add_to_database dan process berfungsi untuk
menyimpan data yang ada pada file ke dalam database program */
add_to_database :-
    read(Term), process(Term).

process(end_of_file) :- !.
process(Term) :-
    assert(Term),
    add_to_database.

/* Predikat main adalah bagian utama dari program yang akan
menjalankan bagian lainnya untuk memberikan rekomendasi film
kepada pengguna */
main :-
    write('Database File Name: '), read(DB),
    see(DB), add_to_database, seen,
    write('Recommendation for User: '), read(User),
    recommend(User, Recommendation),
    write('Recommendation: '), write(Recommendation),
    retractall(likes(_,_)).