import SwiftUI

struct WardrobeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    @State private var filter: CosmeticSlot?

    private var character: CharacterProfile { store.character }

    private var items: [CosmeticItem] {
        guard let filter else { return CosmeticItem.catalog }
        return CosmeticItem.catalog.filter { $0.slot == filter }
    }

    private var nextLockedItem: CosmeticItem? {
        CosmeticItem.catalog
            .filter { character.unlockState(for: $0) == .locked }
            .sorted { $0.effectiveMinLevel < $1.effectiveMinLevel }
            .first
    }

    var body: some View {
        ZStack {
            scheme.movoBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        RoundedCard(padding: 0) {
                            ZStack {
                                LinearGradient(colors: [character.accent.color.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                CharacterPortrait(accent: character.accent.color, stage: character.stage, mood: .happy, gear: character.gear(), targetHeight: 180)
                            }
                            .frame(height: 210)
                        }

                        filterRow

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(items) { item in
                                CosmeticTile(item: item, state: character.unlockState(for: item)) {
                                    handleTap(item)
                                }
                            }
                        }

                        if let nextLockedItem {
                            nextUnlockPanel(nextLockedItem)
                        }
                    }
                    .padding(.horizontal, MovoMetrics.screenPadding)
                    .padding(.bottom, 16)
                }

                MovoPillButton(title: "Save look", accent: .movoLime, action: { dismiss() })
                    .padding(.horizontal, MovoMetrics.screenPadding)
                    .padding(.bottom, 20)
            }
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(scheme.movoTextPrimary)
            }
            Spacer()
            Text("Wardrobe")
                .font(.movoDisplay(18))
                .foregroundStyle(scheme.movoTextPrimary)
            Spacer()
            Text("\(character.totalPoints) pts")
                .font(.movoBody(13, weight: .bold))
                .foregroundStyle(Color.movoLime)
        }
        .padding(.horizontal, MovoMetrics.screenPadding)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    private var filterRow: some View {
        HStack(spacing: 8) {
            MovoChip(title: "All", isSelected: filter == nil, accent: .movoLime) { filter = nil }
            ForEach(CosmeticSlot.allCases) { slot in
                MovoChip(title: slot.displayName, isSelected: filter == slot, accent: .movoLime) { filter = slot }
            }
            Spacer(minLength: 0)
        }
    }

    private func nextUnlockPanel(_ item: CosmeticItem) -> some View {
        let progress = character.unlockProgress(for: item)
        return RoundedCard(borderColor: .movoAmber) {
            HStack {
                Text("Next unlock")
                    .font(.movoBody(13, weight: .bold))
                    .foregroundStyle(scheme.movoTextPrimary)
                Spacer()
                Text(item.requiresChampion ? "Reach Champion" : "Lvl \(item.minLevel)")
                    .font(.movoBody(12, weight: .semibold))
                    .foregroundStyle(Color.movoAmber)
            }
            MovoProgressBar(progress: progress, accent: .movoAmber)
            Text("\(item.requiresChampion ? "Champion" : "Level \(item.minLevel)") unlocks the \(item.name.lowercased()).")
                .font(.movoBody(11))
                .foregroundStyle(scheme.movoTextSecondary)
        }
    }

    private func handleTap(_ item: CosmeticItem) {
        switch character.unlockState(for: item) {
        case .equipped:
            break
        case .owned:
            store.equip(item)
        case .purchasable:
            store.purchase(item)
            store.equip(item)
        case .locked:
            break
        }
    }
}

private struct CosmeticTile: View {
    @Environment(\.colorScheme) private var scheme
    var item: CosmeticItem
    var state: UnlockState
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedCard(borderColor: state == .equipped ? .movoLime : nil) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.movoBody(13, weight: .semibold))
                            .foregroundStyle(scheme.movoTextPrimary)
                        stateLabel
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(state == .locked)
        .opacity(state == .locked ? 0.6 : 1.0)
    }

    @ViewBuilder private var stateLabel: some View {
        switch state {
        case .equipped:
            Text("Equipped").font(.movoBody(10, weight: .bold)).foregroundStyle(Color.movoLime)
        case .owned:
            Text("Owned").font(.movoBody(10)).foregroundStyle(scheme.movoTextSecondary)
        case .purchasable:
            Text("\(item.costPts) pts").font(.movoBody(10, weight: .bold)).foregroundStyle(Color.movoAmber)
        case .locked:
            HStack(spacing: 4) {
                Image(systemName: "lock.fill").font(.system(size: 9))
                Text(item.requiresChampion ? "Champion" : "Lvl \(item.minLevel)")
            }
            .font(.movoBody(10))
            .foregroundStyle(scheme.movoTextSecondary)
        }
    }
}

#Preview {
    WardrobeView().environmentObject(AppStore())
}
