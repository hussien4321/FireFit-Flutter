import 'package:middleware/middleware.dart';
List<Outfit> mockedOutfits = [ _outfit1, _outfit2, _outfit3, _outfit4, _outfit5, _outfit6,];

final _outfit1 =Outfit(
  outfit_id: 1,
  title: 'Shall I buy or not?',
  images: ['assets/outfit1.jpg'],
  style: 'Casual',
  poster: user1,
  likesCount: 5,
  commentsCount: 10,
);

final _outfit2 =Outfit(
  outfit_id: 2,
  title: 'OOTD, Thoughts?',
  images: ['assets/outfit2.jpg'],
  style: 'Casual',
  poster: user4,
  likesCount: 200,
  commentsCount: 49,
);

final _outfit3 =Outfit(
  outfit_id: 3,
  title: 'Gangsta Gym Clothes',
  images: ['assets/outfit3.jpg'],
  style: 'Streetwear',
  poster: user2,
  likesCount: 29,
  commentsCount: 3,
);

final _outfit4 =Outfit(
  outfit_id: 4,
  title: 'My favourite Outfit',
  images: ['assets/outfit4.jpg'],
  style: 'Casual',
  poster: user3,
  likesCount: 3,
  commentsCount: 0,
);

final _outfit5 =Outfit(
  outfit_id: 5,
  title: 'Running Outfit',
  images: ['assets/outfit5.jpg'],
  style: 'Sportswear',
  poster: user1,
  likesCount: -10,
  commentsCount: 3,
);

final _outfit6 =Outfit(
  outfit_id: 6,
  title: 'Dress 2 Impress',
  images: ['assets/outfit6.jpg'],
  style: 'Office',
  poster: user4,
  likesCount: 10,
  commentsCount: 1,
);
