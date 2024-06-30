import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotube/collections/formatters.dart';
import 'package:spotube/components/titlebar/titlebar.dart';
import 'package:spotube/modules/stats/common/artist_item.dart';

import 'package:spotube/provider/history/top.dart';
import 'package:spotube/provider/history/top/tracks.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class StatsArtistsPage extends HookConsumerWidget {
  static const name = "stats_artists";
  const StatsArtistsPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final topTracks = ref.watch(
      historyTopTracksProvider(HistoryDuration.allTime),
    );
    final topTracksNotifier =
        ref.watch(historyTopTracksProvider(HistoryDuration.allTime).notifier);

    final artistsData = useMemoized(
        () => topTracks.asData?.value.artists ?? [], [topTracks.asData?.value]);

    return Scaffold(
      appBar: const PageWindowTitleBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text("Artists"),
      ),
      body: Skeletonizer(
        enabled: topTracks.isLoading && !topTracks.isLoadingNextPage,
        child: InfiniteList(
          onFetchData: () async {
            await topTracksNotifier.fetchMore();
          },
          hasError: topTracks.hasError,
          isLoading: topTracks.isLoading && !topTracks.isLoadingNextPage,
          hasReachedMax: topTracks.asData?.value.hasMore ?? true,
          itemCount: artistsData.length,
          itemBuilder: (context, index) {
            final artist = artistsData[index];
            return StatsArtistItem(
              artist: artist.artist,
              info:
                  Text("${compactNumberFormatter.format(artist.count)} plays"),
            );
          },
        ),
      ),
    );
  }
}
