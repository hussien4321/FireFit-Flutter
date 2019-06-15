import 'package:middleware/middleware.dart';
List<Outfit> mockedOutfits = [ _outfit1, _outfit2, _outfit3, _outfit4, _outfit5, _outfit6,];

final _outfit1 =Outfit(
  outfitId: 1,
  title: 'Shall I buy or not?',
  images: ['https://s2.r29static.com//bin/entry/817/720x864,85/1835142/image.webp'],
  style: 'Casual',
  poster: user1,
  likesCount: 5,
  commentsCount: 10,
);

final _outfit2 =Outfit(
  outfitId: 2,
  title: 'OOTD, Thoughts?',
  images: ['https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fcdn-img.instyle.com%2Fsites%2Fdefault%2Ffiles%2Fstyles%2F684xflex%2Fpublic%2Fimages%2F2017%2F08%2F080217-danaerys-game-thrones-lead.jpg%3Fitok%3DkRAQhQsz&w=400&c=sc&poi=face&q=85'],
  style: 'Casual',
  poster: user4,
  likesCount: 200,
  commentsCount: 49,
);

final _outfit3 =Outfit(
  outfitId: 3,
  title: 'Gangsta Gym Clothes',
  images: ['https://pressfrom.info/upload/images/real/2018/10/19/first-look-daredevil-s-new-costume-reveals-just-how-effed-up-season-3-s-fight-scenes-are__37245_.jpg?content=1'],
  style: 'Streetwear',
  poster: user2,
  likesCount: 29,
  commentsCount: 3,
);

final _outfit4 =Outfit(
  outfitId: 4,
  title: 'My favourite Outfit',
  images: ['https://upload.wikimedia.org/wikipedia/en/thumb/5/5f/Arrow_%28Stephen_Amell%29.jpg/220px-Arrow_%28Stephen_Amell%29.jpg'],
  style: 'Casual',
  poster: user3,
  likesCount: 3,
  commentsCount: 0,
);

final _outfit5 =Outfit(
  outfitId: 5,
  title: 'Running Outfit',
  images: ['https://sm.ign.com/ign_in/cover/t/the-flash/the-flash_uttt.jpg'],
  style: 'Sportswear',
  poster: user1,
  likesCount: -10,
  commentsCount: 3,
);

final _outfit6 =Outfit(
  outfitId: 6,
  title: 'Dress 2 Impress',
  images: ['http://biographyz.com/wp-content/uploads/2018/02/Colin-Donnell.jpg'],
  style: 'Office',
  poster: user4,
  likesCount: 10,
  commentsCount: 1,
);
